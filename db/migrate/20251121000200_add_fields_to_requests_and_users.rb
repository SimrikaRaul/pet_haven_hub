class AddFieldsToRequestsAndUsers < ActiveRecord::Migration[5.1]
  def change
    change_table :requests do |t|
      t.string :request_type
      t.text :notes
      t.string :route
      t.float :route_distance
      t.index :status
    end

    change_table :users do |t|
      t.string :preferred_species
      t.index :role
    end
  end
end
