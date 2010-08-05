require 'rubygems'
require 'rdbi'
gem 'rdbi-driver-postgresql'
require 'rdbi/driver/postgresql'
require 'yaml'

module Connector
  def self.connect
    params = YAML.load_file('database.yml')
    RDBI.connect(:PostgreSQL, params) 
  end
end
