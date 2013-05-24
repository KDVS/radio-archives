class CreateSchema < ActiveRecord::Migration
  def apply
    ActiveRecord::Migration.verbose = false

    create_table :shows do |t|
      t.string :title
      t.string :artist
      t.text   :description
    end

    create_table :recordings do |t|
      t.integer  :show_id
      t.string   :filename
      t.datetime :started
      t.datetime :ended
    end

    create_table :schedule do |t|
      t.integer  :show_id
      t.integer  :dotw
      t.datetime :start
      t.integer  :duration
      t.string   :host
      t.integer  :port
      t.string   :url
    end
  end
end

