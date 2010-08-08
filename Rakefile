$:.unshift 'lib'
require 'connector'
require 'db'
gem 'highline'
require 'highline/import'

desc "Run shotgun with thin against the app"
task :run do
  exec "shotgun -s thin run.rb"
end

task :install_gems do
  sh 'gem install json highline sinatra thin shotgun'
end

namespace :meeting do
  task :add do
    date = ask("Date: ", DateTime)
    $db = DB.new
    $db.create_meeting(date)
  end
end

namespace :db do
  desc "drop and create the database"

  task :init do
    sh "dropdb project_list"
    sh "createdb project_list"
  end

  desc "load the schema"
  task :load do
    dbh = Connector.connect

    statements = File.read('schema.sql').split(/\n---\n/)

    statements.each do |stmt|
      dbh.execute(stmt)
    end
  end

  desc "shorthand for init+load"
  task :reboot => [:init, :load]
end
