class DB
  def search_project_by_name_and_tech(name, techs)
    name.gsub!(/%/, '')
    return [] if name.empty?

    @dbh.execute(%q[
      select p.* 
      from techs t
        inner join project_techs pt
        on t.id = pt.tech_id
          inner join projects p
            on p.id = pt.project_id
      where p.name LIKE ?
        and lower(t.tech) in (] + 
      ('?,' * techs.length).sub(/,$/, '') + 
      ")", "%#{name}%", *techs.map(&:downcase)
    ).fetch(:all, :Struct).
      collect do |project|
        user = user_by_id(project.user_id)
        techs = project_techs(project.id)

        FullProject.new(project, user, techs)
      end
  end

  def search_project_by_name(name)
    name.gsub!(/%/, '')
    return [] if name.empty?
    @dbh.execute("select * from projects where name LIKE ?", "%#{name}%").
      fetch(:all, :Struct).
        collect do |project|
          user = user_by_id(project.user_id)
          techs = project_techs(project.id)

          FullProject.new(project, user, techs)
        end
  end

  def search_project_by_tech(techs)
    @dbh.execute(%q[
      select p.* 
      from techs t
        inner join project_techs pt
        on t.id = pt.tech_id
          inner join projects p
            on p.id = pt.project_id
      where lower(t.tech) in (] + 
      ('?,' * techs.length).sub(/,$/, '') + 
      ")", *techs.map(&:downcase)
    ).fetch(:all, :Struct).
      collect do |project|
        user = user_by_id(project.user_id)
        techs = project_techs(project.id)

        FullProject.new(project, user, techs)
      end
  end
end
