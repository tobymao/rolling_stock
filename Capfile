require "capistrano/setup"
require "capistrano/deploy"
require 'rvm1/capistrano3'
require "capistrano/scm/git"
install_plugin Capistrano::SCM::Git

Dir.glob("lib/capistrano/tasks/*.rake").each { |r| import r }
