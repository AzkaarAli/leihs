class Borrow::ApplicationController < ApplicationController

  layout "borrow"

  before_filter do
    require_role "customer"
  end

  def start
  end

end
