class BusinessSettingsController < ApplicationController
  before_action :require_admin

  def show
    @setting = BusinessSetting.current
  end

  def update
    @setting = BusinessSetting.current
    if @setting.update(setting_params)
      redirect_to business_settings_path, notice: "Configuración del negocio actualizada."
    else
      render :show, status: :unprocessable_entity
    end
  end

  def toggle_active
    @setting = BusinessSetting.current
    @setting.update!(activo: !@setting.activo)
    mensaje = @setting.activo? ? "La tienda está encendida: ya se pueden recibir pedidos por la web." : "La tienda está apagada: no se pueden hacer pedidos por la web."
    redirect_to business_settings_path, notice: mensaje
  end

  private

  def setting_params
    params.require(:business_setting).permit(
      :nombre, :telefono, :direccion, :descripcion, :horario, :historia,
      :color_primario, :color_secundario, :color_acento,
      :whatsapp_negocio, :logo, :foto_hero, :foto_nosotros
    )
  end
end
