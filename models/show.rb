class Show < ActiveRecord::Base
  has_many :recordings
end

unless Show.table_exists?
  puts "Database not found. Creating..."
  load 'db/create_schema.rb'
  schema = CreateSchema.new
  schema.apply
end

