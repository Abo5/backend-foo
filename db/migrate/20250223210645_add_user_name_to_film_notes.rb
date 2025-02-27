class AddUserNameToFilmNotes < ActiveRecord::Migration[8.0]
  def change
    add_column :film_notes, :user_name, :string
  end
end
