class CategoriesController < ApplicationController

  def index
    @categories = if params[:children]
      Category.find(params[:category_id]).children
    else
      Category.all
    end
  end

  def image
    category = Category.find params[:id]
    redirect_to category.image, :status => :moved_permanently
  end

end
  
