# app/controllers/users/sessions_controller.rb
class Users::SessionsController < Devise::SessionsController
  # تجاوز callback الـ check_token_cookie الذي تم تعريفه في ApplicationController
  skip_before_action :check_token_cookie

  include AuthenticationTokenCookie

  # تمت إزالة تجاوز authenticate_user! لأنه غير معرف في هذا السياق.
  # skip_before_action :authenticate_user!, only: [:create, :refresh, :destroy]
  
  skip_before_action :verify_signed_out_user, only: :destroy
  before_action :ensure_jwt_present, only: :destroy
  rescue_from JWT::DecodeError, with: :invalid_token
  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  respond_to :json

  def create
    super
  end

  def refresh
    request.env["devise.mapping"] = Devise.mappings[:user]
    
    token = request.headers['Authorization']&.split(" ")&.last
    if token.blank?
      render json: { error: 'Missing auth token in header.' }, status: :unauthorized and return
    end

    cookie_user_id = cookies.signed[:user_id].to_s.strip
    if cookie_user_id.blank?
      render json: { error: 'Missing or invalid user cookie. Please log in again.' }, status: :unauthorized and return
    end

    begin
      decoded_token = JWT.decode(token, JWT_SECRET, true, { algorithm: 'HS256', verify_expiration: false })
      token_user_id = decoded_token[0]['sub'].to_s.strip
    rescue JWT::DecodeError
      render json: { error: "Token has been tampered with or has been logged out." }, status: :unauthorized and return
    end

    if token_user_id != cookie_user_id
      render json: { error: "Token does not match the user cookie." }, status: :unauthorized and return
    end

    user = User.find_by(id: cookie_user_id)
    if user.present?
      new_token = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first
      if new_token.blank?
        render json: { error: "Unable to generate new token. Please try logging in again." },
               status: :unauthorized and return
      end
      cookies.signed[:user_id] = { value: user.id, expires: 2.hours.from_now }
      render json: {
        message: 'Token refreshed successfully',
        token: new_token,
        cookies: { user_id: cookies.signed[:user_id] },
        user: {
          id: user.id,
          uuid: user.uuid,
          username: user.username,
          email: user.email
        },
        role: user.role
      }, status: :ok
    else
      render json: { error: 'User not found. Please log in again.' }, status: :unauthorized
    end
  end

  def destroy
    token = request.headers['Authorization']&.split(" ")&.last
    if token.blank?
      render json: { error: 'Missing auth token. Please log in again.' }, status: :unauthorized and return
    end

    begin
      decoded_token = JWT.decode(token, JWT_SECRET, true, { algorithm: 'HS256', verify_expiration: false })
      token_user_id = decoded_token[0]['sub'].to_s.strip
      token_jti     = decoded_token[0]['jti']
      token_exp     = decoded_token[0]['exp']
    rescue JWT::DecodeError
      render json: { error: "Token has been tampered with or has been logged out." }, status: :unauthorized and return
    end

    cookie_user_id = cookies.signed[:user_id].to_s.strip
    if cookie_user_id.blank?
      render json: { error: 'Missing or invalid user cookie. Please log in again.' }, status: :unauthorized and return
    end

    if token_user_id != cookie_user_id
      render json: { error: "Token does not match the user cookie." }, status: :unauthorized and return
    end

    jwt_record = JwtDenylist.find_by(jti: token_jti)
    if jwt_record.present?
      render json: { error: "Token has been tampered with or has been logged out." }, status: :unauthorized
    else
      JwtDenylist.create!(jti: token_jti, exp: Time.at(token_exp.to_i))
      render json: { 
        message: 'Logged out successfully',
        cookies: { user_id: cookie_user_id },
        token: token
      }, status: :ok
    end
  end

  private

  def respond_with(resource, _opts = {})
    token = request.env['warden-jwt_auth.token'] || response.headers['Authorization']
    cookies.signed[:user_id] = { value: resource.id, expires: 2.hours.from_now }
    render json: {
      message: 'Logged in successfully',
      token: token,
      cookies: { user_id: cookies.signed[:user_id] },
      user: {
        id: resource.id,
        uuid: resource.uuid,
        username: resource.username,
        email: resource.email
      },
      role: resource.role
    }, status: :ok
  end
end
