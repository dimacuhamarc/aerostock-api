class ItemsController < ApplicationController
  before_action :set_paper_trail_whodunnit
  before_action :authenticate_user!
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

  def create
    @item = Item.new(item_params)
    if @item.save
      render json: @item, status: :created
    else
      render json: {error: 'Unable to create item'}, status: :unprocessable_entity
    end
  end

  def update
    @item = Item.find(params[:id])
    if @item.update(item_params)
      render json: @item
    else
      render json: {error: 'Unable to update item'}, status: :unprocessable_entity
    end
  end

  def destroy
    @item = Item.find(params[:id])
    if @item.destroy
      render json: {message: 'Item deleted successfully'}, status: :ok
    else
      render json: {error: 'Unable to delete item'}, status: :unprocessable_entity
    end
  end

  def audit_log
    @item = Item.find(params[:id])
    @versions = @item.versions

    render json: @versions.map { |version| 
      {
        id: version.id,
        event: version.event, # "create", "update", or "destroy"
        changes: version.changeset, # Details of what was changed
        modified_at: version.created_at,
        # if user is not found, it means the audit log was created by the system
        modified_by: version.whodunnit ? User.find(version.whodunnit).first_name : 'System',
        created_at: @item.created_at,
      }
    }
  end

  def search
    @items = Item.where('name LIKE ?', "%#{params[:query]}%")
    if @items
      render json: @items
    else
      render json: {error: 'No items found'}, status: :not_found
    end
  end

  private 

  def item_params
    params.require(:item).permit(
      :name, 
      :description, 
      :product_number, 
      :serial_number, 
      :quantity, 
      :uom, 
      :date_manufactured, 
      :date_expired, 
      :location, 
      :remarks, 
      :date_arrival_to_warehouse, 
      :authorized_inspection_personnel
    )
  end
end