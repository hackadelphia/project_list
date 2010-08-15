class DB
  def create_project(username, name, description, source_code_url, *techs)
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

  def projects
    @dbh.execute("select * from projects order by id desc").
      fetch(:all, :Struct).
        collect do |project|
          user = user_by_id(project.user_id)
          techs = project_techs(project.id)

          FullProject.new(project, user, techs)
        end
  end

  def delete_project(project_id)
    @dbh.execute("delete from projects where id=?", project_id)
    @dbh.execute("delete from project_techs where project_id=?", project_id)
    @dbh.execute("delete from user_projects_interested where project_id=?", project_id)
  end

  def assign_user_to_project(project_id, username)
    this_user = user(username)
    @dbh.execute("insert into user_projects_interested (project_id, user_id) values (?, ?)", project_id, this_user.id)
  end

  def remove_user_from_project(project_id, username)
    this_user = user(username)
    @dbh.execute("delete from user_projects_interested where project_id = ? and user_id = ?", project_id, this_user.id)
  end

  def assigned_to_project?(project_id, username)
    this_user = user(username)
    @dbh.execute(%q[
        select true 
        from user_projects_interested 
        where project_id = ? and user_id = ?
      ], project_id, this_user.id
    ).fetch(:first, :Struct)[0] rescue nil
  end

  def users_interested_in_project(project_id)
    @dbh.execute(%q[
      select u.* from 
        user_projects_interested upi 
          inner join users u 
          on upi.user_id = u.id 
      where upi.project_id = ?],
      project_id).fetch(:all, :Struct)
  end

  def user_projects(user_id)
    @dbh.execute("select * from projects where user_id=?", user_id).fetch(:all, :Struct)
  end

  def user_project_assignments(user_id)
    @dbh.execute(%q[
      select p.* 
      from user_projects_interested upi 
        inner join projects p 
        on p.id = upi.project_id 
          inner join users u 
          on u.id = upi.user_id
      where u.id = ?], user_id
    ).fetch(:all, :Struct)
  end
end
