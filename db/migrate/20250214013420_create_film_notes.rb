class CreateFilmNotes < ActiveRecord::Migration[8.0]
  def change
    create_table :film_notes do |t|
      t.references :movie, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text    :note, null: false
      t.string  :time_in, null: false
      t.string  :time_out, null: false
      t.string  :action, null: false

      t.timestamps
    end
  end
end