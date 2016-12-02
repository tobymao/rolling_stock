Sequel.migration do
  up do
    run 'CREATE UNIQUE INDEX index_users_on_name
                 ON users USING btree (lower(name));'

    run 'CREATE UNIQUE INDEX index_users_on_email
                 ON users USING btree (lower(email));'
  end

  down do
    run 'DROP INDEX index_users_on_name'
    run 'DROP INDEX index_users_on_email'
  end
end
