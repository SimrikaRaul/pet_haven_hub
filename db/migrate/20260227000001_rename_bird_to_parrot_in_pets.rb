class RenameBirdToParrotInPets < ActiveRecord::Migration[7.0]
  def up
    Pet.where(pet_type: 'bird').update_all(pet_type: 'parrot')
  end

  def down
    Pet.where(pet_type: 'parrot').update_all(pet_type: 'bird')
  end
end
