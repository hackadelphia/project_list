class DB
  def create_meeting(date)
    @dbh.execute("insert into meetings (meeting_time) values (?)", date)
  end

  def meetings
    @dbh.execute("select * from meetings").fetch(:all, :Struct)
  end
end
