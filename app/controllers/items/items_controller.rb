class ItemsController < ApplicationController
  def index
    @items = Item.all
    if @items
      render json: @items
    else
      render json: {error: 'No items found'}, status: :not_found
    end
  end

  def show
    @item = Item.find_by_id(params[:id])
    if @item
      render json: @item
    else
      render json: {error: 'Item not found'}, status: :not_found
    end
  end
end
