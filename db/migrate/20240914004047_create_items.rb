class CreateItems < ActiveRecord::Migration[7.1]
  def change
    create_table :items do |t|
      t.string :name, null: false
      t.string :description, null: false
      t.string :product_number, null: false
      t.string :serial_number, null: false
      t.integer :quantity, null: false
      t.string :uom
      t.date :date_manufactured
      t.date :date_expired
      t.string :location
      t.text :remarks
      t.date :date_arrival_to_warehouse
      t.string :authorized_inspection_personnel

      t.timestamps
    end
  end
end
