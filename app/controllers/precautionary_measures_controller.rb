class PrecautionaryMeasuresController < ApplicationController
  def index
    @precautionary_measures = PrecautionaryMeasure.all.order(:display_order)
  end
end
