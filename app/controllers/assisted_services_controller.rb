class AssistedServicesController < ApplicationController
  def show
    @assisted_service = AssistedService.find_by(id: params[:id])
    return redirect_to(root_path, notice: t('bkx.gone.service')) unless @assisted_service
  end
end
