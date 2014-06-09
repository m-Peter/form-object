class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :Project
      t.string :name

      t.timestamps
    end
  end
end
