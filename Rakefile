$:.unshift 'lib'
require 'connector'

task :load do
  dbh = Connector.connect

  statements = File.read('schema.sql').split(/\n---\n/)

  statements.each do |stmt|
    dbh.execute(stmt)
  end
end
