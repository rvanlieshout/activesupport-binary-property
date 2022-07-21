require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'

  gem 'rails', '7.0.3.1'
  gem 'rspec-rails'
  gem 'sqlite3'
end

require File.expand_path('../spec/dummy/config/environment.rb', __dir__)
ENV['RAILS_ROOT'] ||= File.dirname(__FILE__) + '../../../spec/dummy'

require 'rspec/rails'

require 'activesupport-binary-property'

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")

ActiveRecord::Schema.define do
  create_table :users, force: true do |t|
    t.integer :roles
  end
end

RSpec.configure do |config|
  config.around do |example|
    ActiveRecord::Base.transaction do
      example.run

      raise ActiveRecord::Rollback
    end
  end
end
