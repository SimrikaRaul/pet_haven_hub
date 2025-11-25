class AddFieldsToPets < ActiveRecord::Migration[5.1]
  def change
    change_table :pets do |t|
      t.string :size
      t.string :sex
      t.string :health_status
      t.boolean :vaccinated, default: false
      t.float :lat
      t.float :lon
      t.index :pet_type
      t.index :breed
    end
  end
end
