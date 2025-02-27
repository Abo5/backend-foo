class CreateMovies < ActiveRecord::Migration[8.0]
  def change
    # تأكد من تفعيل امتداد pgcrypto لتوليد UUID تلقائيًا (لمستخدمي PostgreSQL)
    enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')

    create_table :movies do |t|
      t.uuid    :uuid, default: 'gen_random_uuid()', null: false
      t.string  :title, null: false                     # عنوان الفيلم ضروري
      t.string  :runtime, null: false                   # مدة الفيلم بصيغة HH:MM:SS
      t.text    :overview                              # نظرة سريعة عن الفيلم والقصة
      t.string  :production_company                    # الشركة المنتجة
      t.date    :release_date                          # تاريخ الإصدار
      t.string  :director                              # اسم المخرج
      t.text    :cast                                  # قائمة الممثلين (يمكن تخزينها كنص مفصول بفواصل)
      t.string  :poster_url                            # رابط صورة البوستر (png, jpg, ejpg)
      t.string  :trailer_url                           # رابط المقطع الترويجي
      t.uuid    :added_by_user_uuid                    # معرف المراقب الذي أضاف الفيلم
      t.uuid    :approved_by_admin_uuid                # معرف الإدمن الذي اعتمد الفيلم

      t.timestamps
    end

    add_index :movies, :uuid, unique: true
  end
end