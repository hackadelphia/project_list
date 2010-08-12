require 'digest/sha1'
require 'connector'

FullProject = Struct.new(:project, :user, :techs)

class DB
  def initialize
    @dbh = Connector.connect
  end

  def teardown
    @dbh.disconnect
  end

  # XXX
  #
  # authentication is likely vulnerable to a classic replay attack. I don't
  # really care that much.
  #
  # Additionally, the digest isn't a HMAC which has its own set of problems.
  # again with the not caring.
  #
  def plain_authenticated?(username, password)
    return false unless username
    this_user = user(username)
    return false unless this_user
    password_hash(password) == this_user.password
  end

  def crypt_authenticated?(username, crypt_password)
    return false unless username
    this_user = user(username)
    return false unless this_user
    crypt_password == this_user.password
  end

  def password_hash(password)
    Digest::SHA1.hexdigest(password)
  end

  def create_user(username, password, realname, *techs)
    @dbh.execute(%q[
        insert into users 
        (username, password, realname) 
        values 
        (?, ?, ?)
      ],  
      username, 
      password_hash(password), 
      realname
    )

    this_user = @dbh.execute("select * from users where username = ?", username).
      fetch(:first, :Struct)
    
    raise "oh snap" unless this_user

    tech_ids = clobber_techs(techs)
    relate_techs(this_user.id, tech_ids, 'user')

    return this_user.id
  end

  def user(username)
    @dbh.execute("select * from users where username = ?", username).
      fetch(:first, :Struct)
  end

  def user_by_id(user_id)
    @dbh.execute("select * from users where id = ?", user_id).
      fetch(:first, :Struct)
  end

  def clobber_techs(techs)
    # XXX yes, this will frequently fail. let's use our database and its constraints.
    techs.each { |tech| create_tech(tech) rescue nil } 
    return techs(techs).map(&:id)
  end

  def create_tech(tech)
    @dbh.execute("insert into techs (tech) values (?)", tech)
  end

  def tech(tech)
    @dbh.execute("select * from techs where tech = ?", tech).
      fetch(:first, :Struct)
  end

  def techs(techs)
    return [] if techs.empty?

    @dbh.execute("select * from techs where lower(tech) in (" + 
                  ('?,' * techs.length).sub(/,$/, '') + ")", 
                  *techs.map(&:downcase)
                ).fetch(:all, :Struct)
  end

  def all_techs
    @dbh.execute("select tech from techs").fetch(:all).flatten
  end

  def user_techs(user_id)
    @dbh.execute(%q[
      select t.id, t.tech 
      from techs t 
        inner join user_techs ut 
        on ut.tech_id = t.id 
      where ut.user_id = ?
    ], user_id).fetch(:all, :Struct)
  end

  def relate_techs(relation_id, tech_ids, type)
    return unless ['user', 'project'].include?(type)

    sth = @dbh.prepare("insert into #{type}_techs (#{type}_id, tech_id) values (?, ?)")
    tech_ids.each { |tech_id| sth.execute(relation_id, tech_id) }
    sth.finish
  end

  def create_meeting(date)
    @dbh.execute("insert into meetings (meeting_time) values (?)", date)
  end

  def meetings
    @dbh.execute("select * from meetings").fetch(:all, :Struct)
  end

  def create_project(username, name, description, source_code_url, meeting_id, *techs)
    user = user(username)

    @dbh.execute(%q[
                  insert into projects
                  (user_id, name, description, source_code_url)
                  values
                  (?, ?, ?, ?)
                 ],
                 user.id,
                 name,
                 description,
                 source_code_url
                )

    project_id = @dbh.execute("select id from projects where name=?", name).fetch(:first)[0]

    tech_ids = clobber_techs(techs)
    relate_techs(project_id, tech_ids, 'project')

    return project_id
  end

  def project(project_id)
    @dbh.execute("select * from projects where id = ?", project_id).fetch(:first, :Struct)
  end

  def project_by_name(name)
    @dbh.execute("select * from projects where name = ?", name).fetch(:first, :Struct)
  end

  def project_techs(project_id)
    @dbh.execute(%q[
                  select * 
                  from techs t 
                    inner join project_techs pt 
                    on t.id = pt.tech_id 
                  where pt.project_id = ?
                 ], 
                 project_id
                ).fetch(:all, :Struct)
  end

  def projects
    @dbh.execute("select * from projects order by id desc").fetch(:all, :Struct).collect do |project|
      user = user_by_id(project.user_id)
      techs = project_techs(project.id)

      FullProject.new(project, user, techs)
    end
  end

  def user_projects(user_id)
    @dbh.execute("select * from projects where user_id=?", user_id).fetch(:all, :Struct)
  end

  def users_interested_in_project(project_id)
    @dbh.execute(%q[
      select * from 
        user_projects_interested upi 
          inner join users u 
          on upi.user_id = u.id 
      where upi.project_id = ?],
      project_id).fetch(:all, :Struct)
  end
end
