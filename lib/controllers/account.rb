#
# Account routes
#

get '/account/show/:username' do
  @user = $db.user(params[:username])
  return 'user not found' unless @user
  @techs = $db.user_techs(@user.id)
  @projects = $db.user_projects(@user.id)
  @assignments = $db.user_project_assignments(@user.id)

  @title = "User page for user: '#{@user.realname}'"

  haml :show_user
end

get '/account/login_text' do
  return login_text
end

get '/account/create' do
  @title = "Create a new account"
  haml :create_account
end

post '/account/create' do
  username, 
  password, 
  confirm_password, 
  realname,
  techs = 
    params[:username].strip, 
    params[:password].strip, 
    params[:confirm_password].strip, 
    params[:realname].strip,
    params[:techs].to_s.strip.split(/\s*,\s*/)

  if username.empty?
    @error = "Please provide a username"
  elsif username.length > 20
    @error = "Your user name is too long. Under 20 characters."
  elsif password.empty? or confirm_password.empty?
    @error = "Please provide a password and a password confirmation"
  elsif realname.empty?
    @error = "Please provide a real name."
  elsif realname.length > 80
    @error = "Your real name is too long. Under 80 characters."
  elsif password != confirm_password
    @error = "Your passwords do not match"
  elsif $db.user(username)
    @error = "This username already exists."
  end

  if @error
    haml :create_account
  else
    begin
      $db.create_user(username, password, realname, *techs)
      login(username, password)
      redirect '/'
    rescue Exception
      @error = "Unknown Error during creation."
      haml :create_account
    end
  end
end

post '/account/login' do
  username, password = params[:username], params[:password]
  if $db.plain_authenticated?(username, password)
    login(username, password)

    return { :login_successful => true, :username => username }.to_json
  end

  return { :login_successful => false }.to_json 
end

get '/account/logout' do
  [:username, :password].each { |x| session.delete(x) }
  return { :logout_successful => true }.to_json 
end


