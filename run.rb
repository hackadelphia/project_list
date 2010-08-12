$:.unshift File.join(File.expand_path(File.dirname(__FILE__)), 'lib')

require 'sinatra'
require 'haml'
require 'json'
require 'cgi'

require 'db'

$db = DB.new

configure do
  enable :sessions
end

################################################################################
#
# Helpers.
#
################################################################################

def login_text
  return authenticated? ? 
    %Q[
      Account: <a href="/account/show/#{e session[:username]}">#{h session[:username]}</a>
      <a class="logout-link" href="javascript:void(0)" title="Click to logout">(logout)</a>
    ] : "Login"
end

def login(username, password)
  session[:username] = params[:username]
  session[:password] = $db.password_hash(params[:password])
end

def authenticated?
  $db.crypt_authenticated?(session[:username], session[:password])
end

def title(title=nil)
  "Hackadelphia Project List" + (title ? ": #{title}" : "")
end

def h(content)
  CGI.escapeHTML(content)
end

def e(content)
  CGI.escape(content)
end

################################################################################
#
# Controllers.
#
################################################################################

get '/' do
  @full_projects = $db.projects
  haml :index
end

#
# Ajax routes (autocompletion, etc)
#

get '/ajax/list/techs' do
  return $db.all_techs.to_json
end

#
# Account routes
#

get '/account/show/:username' do
  @user = $db.user(params[:username])
  return 'user not found' unless @user
  @techs = $db.user_techs(@user.id)
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
    params[:username], 
    params[:password], 
    params[:confirm_password], 
    params[:realname],
    params[:techs].to_s.split(/\s*,\s*/)

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

#
# Project Routes
#

get '/project/create' do
  haml :create_project
end

post '/project/create' do
  username, 
  name,
  description,
  source_code_url,
  techs = 
    session[:username], 
    params[:name], 
    params[:description], 
    params[:source_code_url],
    params[:techs].to_s.split(/\s*,\s*/)

  if name.empty?
    @error = "Please provide a name"
  elsif name.length > 80
    @error = "Your name is too long. Under 80 characters."
  elsif description.empty?
    @error = "Please provide a description"
  elsif !source_code_url.empty? and source_code_url !~ %r!^(https?|git|svn)://!
    @error = "Please provide a valid URL (git, svn, http, https)"
  elsif $db.project_by_name(name)
    @error = "A project by this name already exists."
  elsif username.nil?
    @error = "Please log in first."
  end

  if @error
    haml :create_project
  else
    begin
      project_id = $db.create_project(username, name, description, source_code_url, nil, *techs)
      redirect "/project/show/#{project_id}"
    rescue Exception
      @error = "Unknown Error during creation."
      haml :create_project
    end
  end
end

get '/project/show/:project_id' do
  @project = $db.project(params[:project_id])
  @user    = $db.user_by_id(@project.user_id)
  @techs   = $db.project_techs(params[:project_id])

  haml :show_project
end

#
# Meeting Routes
#

get '/meeting' do
end

get '/meeting/:date' do
end

