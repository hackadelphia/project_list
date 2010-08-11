require 'digest/sha1'
require 'connector'

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
    @dbh.execute("insert into users (username, password, realname) values (?, ?, ?)", username, password_hash(password), realname)
    this_user = @dbh.execute("select * from users where username = ?", username).fetch(:first, :Struct)
    
    raise "oh snap" unless this_user

    sth = @dbh.prepare("insert into user_techs (user_id, tech_id) values (?, ?)")
    techs.each { |tech| sth.execute(this_user.id, tech) }
    sth.finish
  end

  def user(username)
    @dbh.execute("select * from users where username = ?", username).fetch(:first, :Struct)
  end

  def profile(user_id)
    @dbh.execute("select * from user_profiles where user_id = ?", user_id).fetch(:first, :Struct)
  end

  def create_tech(tech)
    @dbh.execute("insert into techs (tech) values (?)", tech)
  end

  def tech(tech)
    @dbh.execute("select * from techs where tech = ?", tech).fetch(:first, :Struct)
  end

  def techs(techs)
    @dbh.execute("select * from techs where tech in (" + ('?,' * techs.length).sub(/,$/, '') +")", *techs).fetch(:all, :Struct)
  end

  def all_techs
    @dbh.execute("select tech from techs").fetch(:all).flatten
  end

  def user_techs(user_id)
    @dbh.execute("select t.id, t.tech from techs t inner join user_techs ut on ut.tech_id = t.id where ut.user_id = ?", user_id).fetch(:all, :Struct)
  end

  def create_meeting(date)
    @dbh.execute("insert into meetings (meeting_time) values (?)", date)
  end

  def meetings
    @dbh.execute("select * from meetings").fetch(:all, :Struct)
  end

  def projects
    @dbh.execute("select * from projects").fetch(:all, :Struct)
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
