# # app/controllers/concerns/authentication_token_cookie.rb
# module AuthenticationTokenCookie
#     extend ActiveSupport::Concern
  
#     # يمكنك تعريف المفتاح هنا أو نقله إلى إعدادات مركزية (مثل initializers)
#     JWT_SECRET = Rails.application.credentials.devise_jwt_secret_key || '7bd03fb27a565373fad9b498407ca653703076938c66176e88e3816a213965e3ab1d4e29850b2a755a6295e7ab4440d9ed8cb763d0f6542081837b12f14507db34966a7716cacc8104c6d8418ac3f0224913b009f50a6fb73c9b7dd11f2a533c685ce67dcfb07eca036882fcd01386f1156841f622c1ae7075f96c73a329cf3c633fb8879e2f8780999832ba37b834c097440441e9c0432d0f9705c68d72d0c8e68a3f3e73f79012e150d42f707a4bca0d6df438c677e94f9743fd6a8286'
  
#     # يمكن استخدام before_action لتطبيق التحقق تلقائيًا على إجراءات معينة
#     included do
#       before_action :ensure_jwt_present, if: :jwt_required?
#     end
  
#     # التحقق من وجود التوكن في الهيدر
#     def ensure_jwt_present
#       unless request.headers['Authorization'].present?
#         render json: { error: 'Missing auth token' }, status: :unauthorized
#       end
#     end
  
#     # دالة للتحقق من تطابق الكوكيز والتوكن
#     def verify_token_cookie_match
#       token = request.headers['Authorization']&.split(" ")&.last
#       return false unless token
      
#       begin
#         decoded_token = JWT.decode(token, JWT_SECRET, true, { algorithm: 'HS256', verify_expiration: false })
#         token_user_id = decoded_token[0]['sub'].to_s.strip
#         cookie_user_id = cookies.signed[:user_id].to_s.strip
#         token_user_id == cookie_user_id
#       rescue JWT::DecodeError
#         false
#       end
#     end
  
#     # دوال للتعامل مع الأخطاء
#     def invalid_token
#       render json: { error: 'Invalid or expired token' }, status: :unauthorized
#     end
  
#     def not_found
#       render json: { error: 'Resource not found' }, status: :not_found
#     end
  
#     private
  
#     # يمكنك تعديل هذا الشرط لتحديد متى يجب تطبيق التحقق من التوكن
#     def jwt_required?
#       true
#     end
#   end
  # NOTE: بَقينا على نفس الاسم للتوافق، لكن كل ما يخص الكوكيز مُعلَّق
module AuthenticationTokenCookie
  extend ActiveSupport::Concern

  # المفتاح السرّي لتوقيع الـ JWT
  JWT_SECRET =
    Rails.application.credentials.devise_jwt_secret_key ||
    '7bd03fb27a565373fad9b498407ca653703076938c66176e88e3816a213965e3ab1d4e29850b2a755a6295e7ab4440d9ed8cb763d0f6542081837b12f14507db34966a7716cacc8104c6d8418ac3f0224913b009f50a6fb73c9b7dd11f2a533c685ce67dcfb07eca036882fcd01386f1156841f622c1ae7075f96c73a329cf3c633fb8879e2f8780999832ba37b834c097440441e9c0432d0f9705c68d72d0c8e68a3f3e73f79012e150d42f707a4bca0d6df438c677e94f9743fd6a8286'

  included do
    # التحقّق من وجود التوكن في جميع الطلبات
    before_action :ensure_jwt_present, if: :jwt_required?
  end

  # تأكّد من وجود ترويسة Authorization
  def ensure_jwt_present
    return if request.headers['Authorization'].present?

    render json: { error: 'Missing auth token' }, status: :unauthorized
  end

  # -------- جُمِّد كل ما يلي لتعليق العمل بالكوكيز --------
  # def verify_token_cookie_match
  #   …
  # end

  def invalid_token
    render json: { error: 'Invalid or expired token' }, status: :unauthorized
  end

  def not_found
    render json: { error: 'Resource not found' }, status: :not_found
  end

  private

  def jwt_required?
    true
  end
end
