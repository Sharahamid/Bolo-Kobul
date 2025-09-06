class PrivacyPoliciesController < ApplicationController
  def index
    @privacy_policies = PrivacyPolicy.all.order(:display_order)
  end
end
