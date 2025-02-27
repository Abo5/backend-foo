class ApplicationController < ActionController::API
  include ActionController::Cookies
  include AuthenticationTokenCookie
  before_action :check_token_cookie

  JWT_SECRET = Rails.application.credentials.devise_jwt_secret_key || '...'

  def flash
    {}
  end

  private

  def check_token_cookie
    unless verify_token_cookie_match
      render json: { error: 'Invalid token or user cookie.' }, status: :unauthorized
    end
  end

  # مثال للتحقق من دور المستخدم
  def check_user_role
    allowed_roles = %w[admin monitor]
    unless current_user && allowed_roles.include?(current_user.role)
      render json: { error: 'Access Denied: Insufficient permissions' }, status: :forbidden
    end
  end
end
