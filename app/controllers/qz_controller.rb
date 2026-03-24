class QzController < ApplicationController
    skip_before_action :verify_authenticity_token
  
    def sign
      to_sign = request.raw_post
  
      private_key = OpenSSL::PKey::RSA.new(
        File.read(Rails.root.join('config/qztray/private_key.pem'))
      )
  
      signature = Base64.strict_encode64(
        private_key.sign(OpenSSL::Digest::SHA256.new, to_sign)
      )
  
      render plain: signature
    end
  end