require 'rubygems'
require 'active_record'
require 'active_record/fixtures'

path_to_fixtures = File.dirname(__FILE__) + '/../test/fixtures'
fixtures = %w( authors posts comments tags )

namespace :cached_models do
  desc 'Run default task (test)'
  task :default => :test
  
  desc 'Reset the CachedModels data'
  task :reset => [ :teardown, :setup ]

  desc 'Create CachedModels test database tables and load fixtures'
  task :setup => [ :create_tables, :load_fixtures ]

  desc 'Remove all CachedModels data'
  task :teardown => :drop_tables

  desc 'Create CachedModels test database tables'
  task :create_tables => :environment do
    ActiveRecord::Schema.define do
      create_table :authors, :force => true do |t|
        t.string :first_name
        t.string :last_name

        t.timestamps
      end
      
      create_table :posts, :force => true do |t|
        t.integer :author_id
        t.string :title
        t.text :text
        t.datetime :published_at

        t.timestamps
      end
      
      create_table :comments, :force => true do |t|
        t.integer :post_id
        t.string :email
        t.text :text
        
        t.timestamps
      end
      
      create_table :tags, :force => true do |t|
        t.integer :taggable_id
        t.string :taggable_type
        t.string :name
        
        t.timestamps
      end
    end
  end

  desc 'Drops CachedModels test database tables'
  task :drop_tables => :environment do
    ActiveRecord::Base.connection.drop_table :authors
    ActiveRecord::Base.connection.drop_table :posts
    ActiveRecord::Base.connection.drop_table :comments
    ActiveRecord::Base.connection.drop_table :tags
  end

  desc 'Load fixtures'
  task :load_fixtures => :environment do
    fixtures.each { |f| Fixtures.create_fixtures(path_to_fixtures, f) }
  end

  desc 'Test CachedModels'
  task :test => [ :setup, 'test:all' ]

  namespace :test do
    desc 'Run CachedModels tests'
    Rake::TestTask.new(:all) do |t|
      t.test_files = FileList["#{File.dirname( __FILE__ )}/../test/**/*_test.rb"]
      t.verbose = true
    end
  end
end