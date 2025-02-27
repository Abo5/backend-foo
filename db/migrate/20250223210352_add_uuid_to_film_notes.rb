class AddUuidToFilmNotes < ActiveRecord::Migration[8.0]
  def change
    add_column :film_notes, :uuid, :string
  end
end
