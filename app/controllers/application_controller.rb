class ApplicationController < ActionController::API
  # include ActionController::Cookies
  # include AuthenticationTokenCookie
  # before_action :check_token_cookie
  # rescue_from ActionController::RoutingError, with: :render_404

  JWT_SECRET = Rails.application.credentials.devise_jwt_secret_key ||
               '7bd03fb27a565373fad9b498407ca653703076938c66176e88e3816a213965e3ab1d4e29850b2a755a6295e7ab4440d9ed8cb763d0f6542081837b12f14507db34966a7716cacc8104c6d8418ac3f0224913b009f50a6fb73c9b7dd11f2a533c685ce67dcfb07eca036882fcd01386f1156841f622c1ae7075f96c73a329cf3c633fb8879e2f8780999832ba37b834c097440441e9c0432d0f9705c68d72d0c8e68a3f3e73f79012e150d42f707a4bca0d6df438c677e94f9743fd6a8286'

  before_action :authenticate_request   # يتحقّق قبل كل الأكشن

  def flash
    {}
  end

  def raise_not_found!
    raise ActionController::RoutingError, "Not Found"
  end

  private

  def render_404
    respond_to do |format|
      format.html { render file: "#{Rails.root}/public/404.html", status: :not_found }
      format.json { render json: { error: "Not Found" }, status: :not_found }
      format.all  { head :not_found }
    end
  end


  # def check_token_cookie
  #   unless verify_token_cookie_match
  #     render json: { error: 'Invalid token or user cookie.' }, status: :unauthorized
  #   end
  # end

  def authenticate_request
    token = request.headers['Authorization']&.split(' ')&.last
    return render json: { error: 'Missing auth token' }, status: :unauthorized if token.blank?

    begin
      payload = JWT.decode(token, JWT_SECRET, true, algorithm: 'HS256').first
      @current_user = User.find(payload['sub'])
    rescue JWT::DecodeError, ActiveRecord::RecordNotFound
      render json: { error: 'Invalid or expired token' }, status: :unauthorized
    end
  end

  # لا يزال بإمكانك استخدامه داخل بقية الكنترولرز
  def current_user
    @current_user
  end

  # مثال للتحقق من دور المستخدم
  def check_user_role
    allowed_roles = %w[admin monitor]
    unless current_user && allowed_roles.include?(current_user.role)
      render json: { error: 'Access Denied: Insufficient permissions' }, status: :forbidden
    end
  end
end
