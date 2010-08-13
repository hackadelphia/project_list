class DB
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
end
