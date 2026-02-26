class RemoveLocationAndRouteFields < ActiveRecord::Migration[8.1]
  def change
    # Remove location coordinates from pets
    remove_column :pets, :lat, :float, if_exists: true
    remove_column :pets, :lon, :float, if_exists: true
    remove_column :pets, :latitude, :float, if_exists: true
    remove_column :pets, :longitude, :float, if_exists: true
    remove_column :pets, :location, :string, if_exists: true

    # Remove location coordinates from users
    remove_column :users, :latitude, :float, if_exists: true
    remove_column :users, :longitude, :float, if_exists: true

    # Remove route/distance fields from requests
    remove_column :requests, :route, :string, if_exists: true
    remove_column :requests, :route_distance, :float, if_exists: true
  end
end
