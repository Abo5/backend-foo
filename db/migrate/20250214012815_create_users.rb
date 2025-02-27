class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    # تأكد من تفعيل امتداد pgcrypto لتوليد UUID تلقائيًا (لمستخدمي PostgreSQL)
    enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')

    create_table :users do |t|
      t.uuid    :uuid, default: 'gen_random_uuid()', null: false
      t.string  :username, null: false
      t.string  :email, null: false
      t.string  :password_digest, null: false
      t.string  :role, null: false, default: 'monitor' # القيمة الافتراضية "monitor"
      t.text    :bio
      t.string  :avatar_url

      t.timestamps
    end

    add_index :users, :email, unique: true
    add_index :users, :uuid, unique: true
  end
end
