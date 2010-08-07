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

configure do
  enable :sessions
end

get '/' do
  return 'fuuuuuuuck'
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

get '/account/login' do
  username, password = params[:username], params[:password]
  if $db.plain_authenticated?(username, password)
    login(username, password)

    return { :login_successful => true, :username => username }.to_json
  end

  return { :login_successful => false }.to_json 
end
