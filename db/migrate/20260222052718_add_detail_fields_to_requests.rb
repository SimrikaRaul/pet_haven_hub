class AddDetailFieldsToRequests < ActiveRecord::Migration[8.1]
  def change
    add_column :requests, :citizenship_number, :string
    add_column :requests, :phone_number, :string
    add_column :requests, :address, :text
    add_column :requests, :house_type, :string
    add_column :requests, :has_other_pets, :boolean
    add_column :requests, :experience, :text
    add_column :requests, :reason, :text
  end
end
