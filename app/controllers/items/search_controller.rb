module Items
  class SearchController < ApplicationController
    def index
      @items = Item.where('name LIKE ?', "%#{params[:query]}%")
      if @items
        render json: @items
      else
        render json: {error: 'No items found'}, status: :not_found
      end
    end
  end
end
