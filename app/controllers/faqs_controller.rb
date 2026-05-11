class FaqsController < ApplicationController
  def index
    @faqs = Faq.all.order(:display_order)
  end
end
