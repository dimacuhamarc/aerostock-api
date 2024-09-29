class ItemsController < ApplicationController
  before_action :set_paper_trail_whodunnit
  before_action :authenticate_user!

  def index
    if params[:top] == 'true'
      @items = Item.order(quantity: :desc).page(params[:page]).per(params[:items].to_i || 10)
    elsif params[:new_items] == 'true'
      @items = Item.order(created_at: :desc).page(params[:page]).per(params[:items].to_i || 10)
    else
      @items = Item.page(params[:page]).per(params[:items].to_i || 10)
    end
    
    if @items.present?
      render json: {
        items: @items,
        meta: {
          current_page: @items.current_page,
          total_pages: @items.total_pages,
          total_count: @items.total_count
        }
      }
    else
      render json: { error: 'No items found' }, status: :not_found
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

    render json: {
      item: @item,
      audit_log: @versions.reverse.map { |version|
      changes = version.changeset || {}
      changes = "Item created" if version.event == "create"
        {
          id: version.id,
          event: version.event, # "create", "update", or "destroy"
          changes: changes, # Details of what was changed
          modified_at: version.created_at,
          # if user is not found, it means the audit log was created by the system
          modified_by: version.whodunnit ? User.find(version.whodunnit).first_name : 'System',
          created_at: @item.created_at,
        }
      }
    }
  end

  def audit_logs
    @items = Item.all
    @versions = PaperTrail::Version.all
    @audit_logs = []
    @items.each do |item|
      @audit_logs << {
        item: item,
        audit_log: item.versions.map { |version| 
        changes = version.changeset || {}
        changes = "Item created" if version.event == "create"
          {
            id: version.id,
            event: version.event, # "create", "update", or "destroy"
            changes: changes, # Details of what was changed
            modified_at: version.created_at,
            # if user is not found, it means the audit log was created by the system
            modified_by: version.whodunnit ? User.find(version.whodunnit).first_name : 'System',
            created_at: item.created_at,
          }
        }
      }
    end

    render json: @audit_logs
  end

  def search
    @items = Item.where('name LIKE ?', "%#{params[:query]}%")
    if @items
      render json: @items
    else
      render json: {error: 'No items found'}, status: :not_found
    end
  end

  def total_items
    @total_items = Item.all.count
    render json: @total_items
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