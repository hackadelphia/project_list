class DB
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
end
