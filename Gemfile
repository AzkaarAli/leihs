source 'http://rubygems.org'

gem 'rails', '3.2.9'

gem 'mysql2', '~> 0.3.11', :platform => :mri_19
gem 'activerecord-jdbcmysql-adapter', :platform => :jruby
gem 'json', '~> 1.7'
gem "active_hash", "~> 0.9"
gem 'haml', '~> 3.1'

gem 'sass', '~> 3.2'
gem 'coffee-script', '~> 2.2'
gem "coffee-filter", "~> 0.1.1"
gem 'jquery-rails', '~> 2.1'
gem 'jquery-tmpl-rails', '~> 1.1'
gem 'haml_assets', '~> 0.2'

gem 'jruby-openssl', :platform => :jruby
gem 'rails_autolink', '~> 1.0'
gem 'will_paginate', :git => "https://github.com/halloffame/will_paginate.git" # fixing count distinct, alternatives: .count(:id, :distinct => true)
#gem 'will_paginate', '~> 3.0' # alternatives: kaminari
gem 'gettext_i18n_rails', '~> 0.8'
gem 'ruby_parser', '~> 3.0' # gettext dependency that Bundler seems unable to resolve

gem 'barby', '~> 0.5.0'
gem "chunky_png", "~> 1.2"

gem 'mini_magick', '~> 3.4'
gem 'rgl', '~> 0.4.0', :require => 'rgl/adjacency' # use ruby-graphviz instead ?? (already in test group)
gem 'ruby-net-ldap', '~> 0.0.4', :require => 'net/ldap'

gem 'nested_set', '~> 1.7'
gem 'acts-as-dag', :git => "git://github.com/jrust/acts-as-dag.git" #tmp# '~> 2.5.5' # TOOD use instead ?? gem 'dagnabit', '2.2.6'
gem 'geocoder', '~> 1.1'
gem "underscore-rails", "~> 1.4"
# gem "RubyInline", '3.8.2', :require => "inline"


# NOTE: Do not move this to the 'development' group, since we need these
# factories also in production mode to seed our demo data on the demo server
gem 'factory_girl', "~> 4.1"
gem 'factory_girl_rails', "~> 4.1"
gem 'faker'
gem "uuidtools", "~> 2.1" # needed for creating unique ids during tests (factories)

group :assets do # Gems used only for assets and not required in production environments by default.
  gem 'sass-rails', '~> 3.2'
  gem 'coffee-rails', '~> 3.2'
  gem 'uglifier', '~> 1.3'
end

group :development do
  gem 'thin', :platform => :mri_19 # web server (Webrick do not support keep-alive connections)
  gem 'trinidad', :platform => :jruby # web server (Webrick do not support keep-alive connections)
  gem 'gettext', :git => "git://github.com/ruby-gettext/gettext.git"
end

group :profiling, :development do
	gem 'newrelic_rpm', '~> 3.5'
end

group :test, :development do
  gem "growl", "~> 1.0.3"
  gem "guard", "~> 1.5"
  gem "guard-cucumber", "~> 1.2"
  gem "guard-rspec", "~> 2.1"
  gem "guard-spork", "~> 1.2", :platform => :mri_19
  gem "guard-jasmine", "~> 1.10"
  gem "phantomjs", "~> 1.6.0.0" # headless webdriver (UI & JS tests)
  #gem "guard-jasmine-headless-webkit", "~> 0.3.2"
  #gem "jasmine-headless-webkit", "~> 0.8.4"
  #gem "jasmine-rails", "~> 0.1.0" # javascript test environment
  gem "jasminerice", "~> 0.0.10" # needed for implement coffeescript, fixtures and asset pipeline serverd css into jasmine
  gem "rb-fsevent", "~> 0.9"
  gem "ruby_gntp", "~> 0.3.4"
  gem 'pry', "~> 0.9"
  gem 'pry-rails', "~> 0.2"
  gem 'spork'
  gem 'cucumber-rails', '~> 1.3', :require => false
  gem 'database_cleaner'
  gem 'rspec', '~> 2.12', :require => false
  gem 'rspec-rails', '~> 2.12', :require => false
  gem 'nokogiri', '~> 1.5'
  gem 'capybara', '1.1.2'
  gem 'simplecov'
  gem 'launchy', '~> 2.1'
  gem "timecop", "~> 0.5"
  gem 'capybara-screenshot'
  gem 'yard'
end

group :test do
  gem 'rcapture'
  gem 'ruby-graphviz'
end

#group :culerity do
# # http://github.com/langalex/culerity - enable testing of JavaScript views
# gem "culerity"
#end

