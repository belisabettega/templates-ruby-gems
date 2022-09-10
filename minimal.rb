# GEMFILE
########################################

inject_into_file 'Gemfile', before: 'group :development, :test do' do
    <<~RUBY
      gem 'devise'
    RUBY
  end

inject_into_file 'Gemfile', after: 'group :development, :test do' do
    <<-RUBY
    gem 'pry-byebug'
    gem 'pry-rails'
    gem 'dotenv-rails'
    gem 'rubocop', '~> 1.36', require: false
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

  # Dotenv
  ########################################
  run 'touch .env'

  # App controller
  ########################################
  run 'rm app/controllers/application_controller.rb'
  file 'app/controllers/application_controller.rb', <<~RUBY
    class ApplicationController < ActionController::Base
        before_action :authenticate_user!
    end
  RUBY

  # migrate + pundit
  ########################################
  rails_command 'db:migrate'
  rails_command 'g pundit:install'

end