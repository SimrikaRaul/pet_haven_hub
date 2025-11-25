class CreateCompletePetHavenSchema < ActiveRecord::Migration[5.1]
  def change

    # ---- USERS TABLE ----
    add_column(:users, :phone, :string) unless column_exists?(:users, :phone)
    add_column(:users, :address, :string) unless column_exists?(:users, :address)
    add_column(:users, :city, :string) unless column_exists?(:users, :city)
    add_column(:users, :country, :string) unless column_exists?(:users, :country)
    add_column(:users, :latitude, :float) unless column_exists?(:users, :latitude)
    add_column(:users, :longitude, :float) unless column_exists?(:users, :longitude)
    add_column(:users, :preferred_species, :string) unless column_exists?(:users, :preferred_species)
    add_column(:users, :bio, :text) unless column_exists?(:users, :bio)

    add_index(:users, :email, unique: true) unless index_exists?(:users, :email)
    add_index(:users, :role) unless index_exists?(:users, :role)

    # ---- PETS TABLE ----
    add_column(:pets, :breed, :string) unless column_exists?(:pets, :breed)
    add_column(:pets, :age, :decimal, precision: 4, scale: 2) unless column_exists?(:pets, :age)
    add_column(:pets, :size, :string) unless column_exists?(:pets, :size)
    add_column(:pets, :sex, :string) unless column_exists?(:pets, :sex)
    add_column(:pets, :health_status, :string) unless column_exists?(:pets, :health_status)
    add_column(:pets, :vaccinated, :boolean, default: false) unless column_exists?(:pets, :vaccinated)
    add_column(:pets, :available, :boolean, default: true) unless column_exists?(:pets, :available)
    add_column(:pets, :description, :text) unless column_exists?(:pets, :description)
    add_column(:pets, :city, :string) unless column_exists?(:pets, :city)
    add_column(:pets, :country, :string) unless column_exists?(:pets, :country)
    add_column(:pets, :latitude, :float) unless column_exists?(:pets, :latitude)
    add_column(:pets, :longitude, :float) unless column_exists?(:pets, :longitude)

    add_index(:pets, :pet_type) unless index_exists?(:pets, :pet_type)
    add_index(:pets, :breed) unless index_exists?(:pets, :breed)
    add_index(:pets, :available) unless index_exists?(:pets, :available)
    add_index(:pets, :user_id) unless index_exists?(:pets, :user_id)

    # ---- REQUESTS TABLE ----
    add_column(:requests, :request_type, :string) unless column_exists?(:requests, :request_type)
    add_column(:requests, :notes, :text) unless column_exists?(:requests, :notes)
    add_column(:requests, :route, :string) unless column_exists?(:requests, :route)
    add_column(:requests, :route_distance, :float) unless column_exists?(:requests, :route_distance)
    add_column(:requests, :scheduled_date, :datetime) unless column_exists?(:requests, :scheduled_date)
    add_column(:requests, :completed_at, :datetime) unless column_exists?(:requests, :completed_at)
    add_column(:requests, :rejection_reason, :text) unless column_exists?(:requests, :rejection_reason)

    add_index(:requests, :status) unless index_exists?(:requests, :status)
    add_index(:requests, :user_id) unless index_exists?(:requests, :user_id)
    add_index(:requests, :pet_id) unless index_exists?(:requests, :pet_id)
    add_index(:requests, :request_type) unless index_exists?(:requests, :request_type)
    add_index(:requests, [:user_id, :created_at]) unless index_exists?(:requests, [:user_id, :created_at])
  end
end
