class ProcessFlowsController < ApplicationController
  def index
    @process_flows = ProcessFlow.all.order(:display_order)
  end
end
