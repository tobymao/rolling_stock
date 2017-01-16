require_relative 'db'

Sequel::Model.plugin :auto_validations
Sequel::Model.plugin :prepared_statements
Sequel::Model.plugin :prepared_statements_associations
Sequel::Model.plugin :timestamps, update_on_create: true
Sequel::Model.plugin :touch
Sequel.default_timezone = :utc
Sequel.extension :migration
Sequel.extension :pg_array_ops, :pg_json_ops
# This needs to be loaded after migration
DB.extension :pg_array, :pg_json, :pg_enum

if ENV['RACK_ENV'] == 'development'
  require 'logger'
  DB.loggers << Logger.new($stdout)
end
