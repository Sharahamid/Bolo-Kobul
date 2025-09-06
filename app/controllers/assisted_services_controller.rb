class AssistedServicesController < ApplicationController
  def show
    @assisted_service = AssistedService.find(params[:id])
  end
end
