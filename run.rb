$:.unshift File.join(File.expand_path(File.dirname(__FILE__)), 'lib')

require 'sinatra'
require 'haml'
require 'json'
require 'cgi'

require 'db'

$db = DB.new
$meetings = $db.meetings

configure do
  enable :sessions
end

require 'helpers'
require 'controllers/root'
require 'controllers/ajax'
require 'controllers/account'
require 'controllers/project'
require 'controllers/meeting'
