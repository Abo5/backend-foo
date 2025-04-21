# config/initializers/cors.rb
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # اسمح فقط بطلبات المتصفّح القادمة من واجهة Next.js
    origins 'http://127.0.0.1:3000', 'http://localhost:3000'

    resource '*',
             headers:     :any,
             methods:     %i[get post patch put delete options head],
             expose:      ['Authorization'], # يرسل الهيدر JWT للمتصفّح
             credentials: true               # يسمح بتمرير الكوكيز مع الطلب
  end
end

