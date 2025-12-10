class AddImageToPets < ActiveRecord::Migration[5.1]
  def change
    add_column :pets, :image, :string
  end
end
