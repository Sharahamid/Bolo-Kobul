class TermsOfUsesController < ApplicationController
  def index
    @terms_of_uses = TermsOfUse.all.order(:display_order)
  end
end
