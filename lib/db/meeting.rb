class DB
  def create_meeting(date)
    @dbh.execute("insert into meetings (meeting_time) values (?)", date)
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
end
