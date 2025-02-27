class CreateFilmRatings < ActiveRecord::Migration[8.0]
  def change
    create_table :film_ratings do |t|
      t.references :movie, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :classification, null: false  # التصنيف باستخدام enum مثل: PG12, G, PG, PG15, R15, R18

      t.timestamps
    end
  end
end