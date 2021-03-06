require "rvm/capistrano"                  # Load RVM's capistrano plugin.
set :rvm_type, :system
#set :rvm_ruby_string, '1.9.2'        # Or whatever env you want it to run in.

require "bundler/capistrano"


set :application, "leihs-test-old"

set :scm, :git
set :repository,  "git://github.com/zhdk/leihs.git"
set :branch, "master"
set :deploy_via, :remote_cache

set :db_config, "/home/leihs/#{application}/database.yml"
set :app_config, "/home/leihs/#{application}/environment.rb"
set :ldap_config, "/home/leihs/#{application}/LDAP.yml"
set :use_sudo, false

set :rails_env, "production"

default_run_options[:shell] = false

set :deploy_to, "/home/leihs/#{application}"

role :app, "leihs@rails.zhdk.ch"
role :web, "leihs@rails.zhdk.ch"
role :db,  "leihs@rails.zhdk.ch", :primary => true

task :retrieve_db_config do
  # DB credentials needed by Sphinx, mysqldump etc.
  get(db_config, "/tmp/leihs_db_config.yml")
  dbconf = YAML::load_file("/tmp/leihs_db_config.yml")["production"]
  set :sql_database, dbconf['database']
  set :sql_host, dbconf['host']
  set :sql_username, dbconf['username']
  set :sql_password, dbconf['password']
end

task :link_config do
  if File.exist?("#{release_path}/config/LDAP.yml")
    run "rm #{release_path}/config/LDAP.yml"
    run "ln -s #{ldap_config} #{release_path}/config/LDAP.yml"
  end
  run "rm -f #{release_path}/config/database.yml"
  run "rm -f #{release_path}/config/environment.rb"
  
  run "ln -s #{db_config} #{release_path}/config/database.yml"
  run "ln -s #{app_config} #{release_path}/config/environment.rb"
end

task :link_attachments do
	run "rm -rf #{release_path}/public/images/attachments"
	run "ln -s #{deploy_to}/#{shared_dir}/attachments #{release_path}/public/images/attachments"

  run "rm -rf #{release_path}/public/attachments"
  run "ln -s #{deploy_to}/#{shared_dir}/attachments #{release_path}/public/attachments"
end

task  :link_db_backups do
  run "rm -rf #{release_path}/db/backups"
  run "ln -s #{deploy_to}/#{shared_dir}/db_backups #{release_path}/db/backups"
end

task :link_sphinx do
  run "rm -rf #{release_path}/db/sphinx"
  run "ln -s #{deploy_to}/#{shared_dir}/sphinx #{release_path}/db/sphinx"
end

task :make_tmp do
	run "mkdir -p #{release_path}/tmp/sessions #{release_path}/tmp/cache"
end

task :chmod_tmp do
  run "chmod g-w #{release_path}/tmp"
end

task :configure_sphinx do
 run "cd #{release_path} && RAILS_ENV='production' bundle exec rake ts:config"
 
  run "sed -i 's/port: 3342/port: 3392/' #{release_path}/config/sphinx.yml"
  run "sed -i 's/port: 3343/port: 3393/' #{release_path}/config/sphinx.yml"
  run "sed -i 's/port: 3344/port: 3394/' #{release_path}/config/sphinx.yml"

  run "sed -i 's/listen: 127.0.0.1:3342/port: 3392/' #{release_path}/config/sphinx.yml"
  run "sed -i 's/listen: 127.0.0.1:3343/port: 3393/' #{release_path}/config/sphinx.yml"
  run "sed -i 's/listen: 127.0.0.1:3344/port: 3394/' #{release_path}/config/sphinx.yml"

 run "sed -i 's/sql_host =.*/sql_host = #{sql_host}/' #{release_path}/config/production.sphinx.conf"
 run "sed -i 's/sql_user =.*/sql_user = #{sql_username}/' #{release_path}/config/production.sphinx.conf"
 run "sed -i 's/sql_pass =.*/sql_pass = #{sql_password}/' #{release_path}/config/production.sphinx.conf"
 run "sed -i 's/sql_db =.*/sql_db = #{sql_database}/' #{release_path}/config/production.sphinx.conf"
 run "sed -i 's/sql_sock.*//' #{release_path}/config/production.sphinx.conf"

  run "sed -i 's/listen = 127.0.0.1:3342/listen = 127.0.0.1:3392/' #{release_path}/config/production.sphinx.conf"
  run "sed -i 's/listen = 127.0.0.1:3343/listen = 127.0.0.1:3393/' #{release_path}/config/production.sphinx.conf"
  run "sed -i 's/listen = 127.0.0.1:3344/listen = 127.0.0.1:3394/' #{release_path}/config/production.sphinx.conf"

end

task :migrate_database do
  # Produce a string like 2010-07-15T09-16-35+02-00
  date_string = DateTime.now.to_s.gsub(":","-")
  dump_dir = "#{deploy_to}/#{shared_dir}/db_backups"
  dump_path =  "#{dump_dir}/#{sql_database}-#{date_string}.sql"
  # If mysqldump fails for any reason, Capistrano will stop here
  # because run catches the exit code of mysqldump
  run "mysqldump -h #{sql_host} --user=#{sql_username} --password=#{sql_password} -r #{dump_path} #{sql_database}"
  run "bzip2 #{dump_path}"

  # Migration here 
  # deploy.migrate should work, but is buggy and is run in the _previous_ release's
  # directory, thus never runs anything? Strange.
  #deploy.migrate
  run "cd #{release_path} && RAILS_ENV='production' bundle exec rake db:migrate"
end

# The built-in capistrano/bundler integration seems broken: It does not cd to release_path but instead
# to the previous release, which has the wrong Gemfile. This fixes that, but of course means we cannot use 
# the built-in bundler support.
task :bundle_install do
  run "cd #{release_path} && bundle install --gemfile '#{release_path}/Gemfile' --path '#{deploy_to}/#{shared_dir}/bundle' --deployment --without development test"
end

task :modify_config do
  # On staging/test, we don't want to deliver e-mail
  run "sed -i 's/config.action_mailer.perform_deliveries = true/config.action_mailer.perform_deliveries = false/' #{release_path}/config/environments/production.rb"
end

task :stop_sphinx do
  run "cd #{release_path} && RAILS_ENV='production' bundle exec rake ts:stop"
end

task :start_sphinx do
  run "cd #{release_path} && RAILS_ENV='production' bundle exec rake ts:reindex"
  run "cd #{release_path} && RAILS_ENV='production' bundle exec rake ts:start"
end


namespace :deploy do
	task :start do
	# we do absolutely nothing here, as we currently aren't
	# using a spinner script or anything of that sort.
          run "cd #{release_path} && passenger start -p 3005 -e production -d"
	end

   task :restart, :roles => :app, :except => { :no_release => true } do
     # We cannot use Passenger on the server because this app runs with a legacy Ruby 1.8.7 and legacy Rails.
     # That's why we have to restart using a proxied standalone Passenger server.
     #run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
     run "cd #{release_path} && passenger stop -p 3005 && passenger start -p 3005 -e production -d"
   end
   
   # This overwrites the (broken, when using Bundler) deploy:migrate task
   task :migrate do
   end

end


before "deploy", "retrieve_db_config"
before "deploy:cold", "retrieve_db_config"

after "deploy:create_symlink", :link_config
after "deploy:create_symlink", :link_attachments
after "deploy:create_symlink", :link_db_backups
after "deploy:create_symlink", :chmod_tmp

after "link_config", :migrate_database
after "migrate_database", :configure_sphinx

before "deploy:restart", :make_tmp
after "deploy:restart", :stop_sphinx
before "stop_sphinx", :link_sphinx

after "deploy", :start_sphinx
after "deploy:cold", :start_sphinx
after "deploy", "deploy:cleanup"
