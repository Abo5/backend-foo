# app/controllers/users/sessions_controller.rb
class Users::SessionsController < Devise::SessionsController
  include AuthenticationTokenCookie   # يحتوي JWT_SECRET و invalid_token …

  skip_before_action :authenticate_request, only: %i[create refresh]
  skip_before_action :verify_signed_out_user, only: :destroy
  before_action       :ensure_jwt_present,      only: :destroy

  respond_to :json
  rescue_from JWT::DecodeError, with: :invalid_token
  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  # POST /login
  def create
    super   # يثق بـ Devise لإرجاع التوكن في env
  end

  # POST /login/refresh
  def refresh
    request.env['devise.mapping'] = Devise.mappings[:user]

    token  = request.headers['Authorization']&.split(' ')&.last
    return render json: { error: 'Missing auth token' }, status: :unauthorized if token.blank?

    payload = JWT.decode(token, JWT_SECRET, true, algorithm: 'HS256',
                         verify_expiration: false).first
    user    = User.find(payload['sub'])

    new_token = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first
    render json: success_payload(user, new_token).merge(message: 'Token refreshed successfully')
  end

  # DELETE /logout
  def destroy
    token = request.headers['Authorization'].split(' ').last
    payload = JWT.decode(token, JWT_SECRET, true, algorithm: 'HS256',
                         verify_expiration: false).first
    JwtDenylist.create!(jti: payload['jti'], exp: Time.at(payload['exp']))

    render json: { message: 'Logged out successfully' }
  end

  private

  # يُستدعَى من Devise بعد تسجيل الدخول
  def respond_with(resource, _opts = {})
    token = request.env['warden-jwt_auth.token'] || response.headers['Authorization']
    render json: success_payload(resource, token).merge(message: 'Logged in successfully')
  end

  def success_payload(user, token)
    {
      token: token,
      user:  {
        id:       user.id,
        uuid:     user.uuid,
        username: user.username,
        email:    user.email
      },
      role:  user.role
    }
  end
end
