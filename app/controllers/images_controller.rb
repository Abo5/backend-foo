class ImagesController < ApplicationController
    # السماح بعرض الصور بدون التحقق من التوكن
    skip_before_action :check_token_cookie
    skip_before_action :ensure_jwt_present
  
    def show
      # البحث باستخدام المفتاح (key) بدلاً من البحث بواسطة uuid للفيلم
      blob = ActiveStorage::Blob.find_by(key: params[:uuid])
      if blob.present?
        redirect_to rails_blob_url(blob, disposition: "inline")
      else
        render json: { error: 'Image not found' }, status: :not_found
      end
    end      
  end
  