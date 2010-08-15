class DB
  def create_meeting(date)
    @dbh.execute("insert into meetings (meeting_time) values (?)", date)
  end

  def project_assigned_to_any_meeting?(project_id)
    @dbh.execute(%q[select true from project_meeting_assignment where project_id = ?]).fetch(:first)[0] rescue nil
  end

  def project_assigned_to_meeting?(project_id, meeting_id)
    @dbh.execute(%q[
      select true
      from project_meeting_assignment
      where project_id = ? and meeting_id = ?
    ], project_id, meeting_id).fetch(:first)[0] rescue nil
  end

  def add_project_to_meeting(project_id, meeting_id)
    @dbh.execute(%q[
      insert into project_meeting_assignment 
      (project_id, meeting_id) 
      values (?, ?)
      ],
      project_id, 
      meeting_id
    )
  end

  def remove_project_from_meeting(project_id, meeting_id)
    @dbh.execute(%q[delete from project_meeting_assignment where project_id = ? and meeting_id = ?], project_id, meeting_id)
  end

  def meeting(meeting_id)
    @dbh.execute("select * from meetings where id = ?", meeting_id).fetch(:first, :Struct)
  end

  def meetings
    @dbh.execute("select * from meetings").fetch(:all, :Struct)
  end

  def projects_for_meeting(meeting_id)
    @dbh.execute(%q[
      select p.* 
      from projects p 
        inner join project_meeting_assignment pma
        on p.id = pma.project_id
          inner join meetings m
            on m.id = pma.meeting_id
      where m.id = ?
    ], meeting_id).
      fetch(:all, :Struct).
        collect do |project|
          user = user_by_id(project.user_id)
          techs = project_techs(project.id)

          FullProject.new(project, user, techs)
        end
  end

  def meetings_for_project(project_id)
    @dbh.execute(%q[
      select m.* 
      from meetings m 
        inner join project_meeting_assignment pma
        on m.id = pma.meeting_id
          inner join projects p
            on p.id = pma.project_id
      where p.id = ?
    ], project_id).fetch(:all, :Struct)
  end
end
