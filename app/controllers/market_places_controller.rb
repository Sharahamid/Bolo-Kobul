class MarketPlacesController < ApplicationController
  def index
    if params[:market_place_type].present?
      market_place_type = MarketPlaceType.find_by(name: params[:market_place_type])
      @market_places = market_place_type.market_places.approved if market_place_type.present?
    else
      @market_places = MarketPlace.approved
    end


    if params[:location].present?
      @market_places = @market_places.where(location: params[:location])
    end

    if params[:price_range].present?
      price_range = params[:price_range].split(',')
      min_price = price_range[0]&.to_i
      max_price = price_range[1]&.to_i
      @market_places = @market_places.where('cost >= ? AND cost <= ?', min_price, max_price)
    end

  end

  def show
    @market_place = MarketPlace.find(params[:id])
  end
end
