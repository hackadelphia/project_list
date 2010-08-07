$:.unshift File.join(File.expand_path(File.dirname(__FILE__)), 'lib')

require 'sinatra'
require 'haml'
require 'json'

require 'db'

$db = DB.new

def login(username, password)
  session[:username] = params[:username]
  session[:password] = $db.password_hash(params[:password])
end

def authenticated?
  $db.crypt_authenticated?(session[:username], session[:password])
end

def login_text
  return authenticated? ? 
    %Q[
      Account: #{session[:username]}
      <a id="logout-link" href="javascript:void(0)" title="Click to logout">(logout)</a>
    ] : "Login"
end

def title(title=nil)
  "Hackadelphia Project List" + (title ? ": #{title}" : "")
end

configure do
  enable :sessions
end

get '/' do
  haml :index
end

get '/account/create' do
  haml :create_account
end

post '/account/create' do
  username, password, realname = params[:username], params[:password], params[:realname]
  $db.create_user(username, password, realname)
  login(username, password)
  redirect '/'
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
