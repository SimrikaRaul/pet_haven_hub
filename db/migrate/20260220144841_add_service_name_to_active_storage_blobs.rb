class AddServiceNameToActiveStorageBlobs < ActiveRecord::Migration[8.1]
  def change
    unless column_exists?(:active_storage_blobs, :service_name)
      add_column :active_storage_blobs, :service_name, :string, null: false, default: 'local'
      change_column_default :active_storage_blobs, :service_name, from: 'local', to: nil
    end
  
    unless table_exists?(:active_storage_variant_records)
      create_table :active_storage_variant_records do |t|
        t.belongs_to :blob, null: false, index: false
        t.string :variation_digest, null: false

        t.index [:blob_id, :variation_digest], name: :index_active_storage_variant_records_uniqueness, unique: true
        t.foreign_key :active_storage_blobs, column: :blob_id
      end
    end
  end
end

