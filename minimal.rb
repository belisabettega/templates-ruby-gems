require 'open-uri'
# GEMFILE
########################################
inject_into_file 'Gemfile', before: 'group :development, :test do' do
    <<~RUBY
      gem 'devise'
      gem 'simple_token_authentication'
    RUBY
  end

inject_into_file 'Gemfile', after: 'group :development, :test do' do
    <<-RUBY
    gem 'pry-byebug'
    gem 'pry-rails'
    gem 'dotenv-rails'
    gem 'rubocop', '~> 1.36', require: false
    gem 'rspec-rails'
    RUBY
end

inject_into_file 'Gemfile', after: 'group :test do' do
  <<-RUBY
  gem 'factory_bot_rails'
  gem 'faker'
  RUBY
end

# AFTER BUNDLE
########################################
after_bundle do
    # Git ignore
  ########################################
  append_file '.gitignore', <<~TXT
  # Ignore .env file containing credentials.
  .env*
  TXT

    # Devise install + user
  ########################################
  generate('devise:install')
  generate('devise', 'User')
  run "spring stop"
  

  # Dotenv
  ########################################
  run 'touch .env'

  # App controller
  ########################################
  run 'rm app/controllers/application_controller.rb'
  file 'app/controllers/application_controller.rb', <<~RUBY
    class ApplicationController < ActionController::Base
        #{  "protect_from_forgery with: :exception\n" if Rails.version < "5.2"} before_action :authenticate_user!
    end
  RUBY

  # rspec + pundit install
  ########################################
  run 'bundle add pundit'
  run 'bundle install'
  generate('pundit:install')
  run "spring stop"
  generate('rspec:install')
  run "guard init"

  # simple token autjentication gem setup
  #######################################
  generate("migration addTokenToUsers 'authentication_token:string{30}:uniq'")
  run "spring stop"
end