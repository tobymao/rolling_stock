set :application, 'rolling_tock'
set :rvm1_ruby_version, 'ruby-2.3.1'
set :repo_url, 'git@github.com:tobymao/rolling_stock.git'
set :deploy_to, '/home/deploy/apps/rolling_stock'
set :current_dir, "#{fetch(:deploy_to)}/current"
set :tmp_dir, "#{fetch(:deploy_to)}/tmp"
set :default_env, { 'RACK_ENV' => 'production' }
set :ssh_options, forward_agent: true

before 'deploy', 'rvm1:install:ruby'
before 'deploy', 'rvm1:install:gems'

after 'deploy:restart', 'deploy:cleanup'
after 'deploy', 'deploy:copy'
after 'deploy', 'deploy:migrate'

namespace :deploy do
  desc 'Rolling restart'
  task :restart do
    on roles :all do
      within fetch(:current_dir) do
        execute :bundle, 'exec thin restart -C config/thin.yml'
      end
    end
  end

  desc 'Start the thin server'
  task :start do
    on roles :all do
      within fetch(:current_dir) do
        execute :bundle, 'exec thin start -C config/thin.yml'
      end
    end
  end

  desc 'Stop this server'
  task :stop do
    on roles :all do
      within fetch(:current_dir) do
        execute :bundle, 'exec thin stop -C config/thin.yml'
      end
    end
  end

  task :copy do
    on roles :all do
      upload! '.env.rb', fetch(:current_dir)
    end
  end

  task :migrate do
    on roles :all do
      within fetch(:current_dir) do
        execute :bundle, 'exec rake prod_up'
      end
    end
  end
end
