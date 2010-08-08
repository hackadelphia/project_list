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
  haml :index
end

#
# Account routes
#

get '/account/show/:username' do
  @user = $db.user(params[:username])
  return 'user not found' unless @user
  @techs = $db.techs(@user.id)
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
  if password != confirm_password
    @error = "Your passwords do not match"
    haml :create_account
  else
    $db.create_user(username, password, realname, *techs)
    login(username, password)
    redirect '/'
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
