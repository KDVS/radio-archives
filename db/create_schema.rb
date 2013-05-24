class CreateSchema < ActiveRecord::Migration
  def apply
    ActiveRecord::Migration.verbose = false

    create_table :shows do |t|
      t.string   :title
      t.string   :artist
      t.text     :description
      t.string   :genre
      t.integer  :dotw
      t.datetime :start
      t.integer  :duration
      t.string   :host
      t.integer  :port
      t.string   :url
      t.integer  :schedule_id
    end

    create_table :recordings do |t|
      t.integer  :show_id
      t.string   :filename
      t.string   :title
      t.datetime :started
      t.datetime :finished
    end
  end
end

