require 'digest/sha1'
require 'connector'

FullProject = Struct.new(:project, :user, :techs)

class DB
  def initialize
    @dbh = Connector.connect
  end

  def teardown
    @dbh.disconnect
  end
end

require 'db/authen'
require 'db/user'
require 'db/tech'
require 'db/search'
require 'db/project'
require 'db/meeting'
