module Api
  module V1
    # Hereda de ApplicationController (no ActionController::API) para
    # reutilizar la autenticación por sesión/cookie existente tal cual está;
    # solo cambia cómo se responde cuando falla la autorización.
    class BaseController < ApplicationController
      private

      def require_admin_or_supervisor_json
        unless current_user&.admin? || current_user&.supervisor?
          render json: { error: 'No tienes permisos para acceder a esta sección.' }, status: :forbidden
        end
      end
    end
  end
end
