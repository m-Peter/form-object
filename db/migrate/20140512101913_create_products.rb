class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :title
      t.text :description
      t.decimal :price
      t.integer :units

      t.timestamps
    end
  end
end
