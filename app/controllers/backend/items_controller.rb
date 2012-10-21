class Backend::ItemsController < Backend::BackendController
  
  before_filter do
    params[:id] ||= params[:item_id] if params[:item_id]
    if params[:id]
      @item = current_inventory_pool.items.where(:id => params[:id]).first
      @item ||= Item.unscoped { current_inventory_pool.own_items.where(:id => params[:id]).first }
    end

    @location = Location.find(params[:location_id]) if params[:location_id]
    
    @model = if @item
                @item.model
             elsif params[:model_id]
                Model.find(params[:model_id])
             end
  end

######################################################################
  
  def index(with = params[:with])
    items = if @model
      current_inventory_pool.items.in_stock.scoped_by_model_id @model
    else
      current_inventory_pool.items
    end
    respond_to do |format|
      format.json { render :json => view_context.json_for(items, with) }
    end
  end

  def new(id = params[:original_id])
    if id.blank?
      @item = Item.new
      @item.model = @model if @model
      @item.invoice_date = Date.yesterday
    else 
      @item = Item.find(id).dup # NOTE use .dup instead of .clone (from Rails 3.1)
      @item.serial_number = nil
      @item.name = nil
    end
    @item.inventory_code = Item.proposed_inventory_code(current_inventory_pool)
    @item.owner = current_inventory_pool
    if @current_user.access_level_for(current_inventory_pool) < 2
      @item.inventory_pool = current_inventory_pool
    end
    @item.is_inventory_relevant = (is_super_user? ? true : false)
    render :action => 'show'
  end

  def create
    @item = Item.new(:owner => current_inventory_pool)
    flash[:notice] = _("New item created.")
    update
  end

  # TODO: we do not check here who is allowed to do what - i.e. a level 1 manager can
  #       update items directly through the backend - even though the frontend wouldn't let him
  def update
    get_histories

    params[:item][:location] = Location.find_or_create(params[:location]) if params[:location]

# TODO: Move to before_save, this never fires this way, but in before_save we are lacking
# a current_user
#     if @item.inventory_pool_id_changed?
#       @item.log_history(_("Item %s moved responsible department from %s to %s") % 
#                         [@item, InventoryPool.find(@item.inventory_pool_id_was), @item.inventory_pool],
#                         current_user)
#     end
#     
#     if @item.owner_id_changed?
#       @item.log_history(_("Item %s moved owner from %s to %s") % 
#                         [@item, InventoryPool.find(@item.owner_id_was), @item.owner],
#                         current_user)
#     end

    if to_retire = params[:item].delete(:to_retire)
      unless @item.retired?
        @item.retired = Date.today
      else
        # we keep the existing stored date
      end
    elsif @item.retired?
      params[:item].delete(:retired_reason)
      @item.retired_reason = nil
      @item.retired = nil
    end

    if @item.update_attributes(params[:item])
      flash[:notice] = _("Item saved.") #tmp# unless flash[:notice]
      if params[:copy].blank?
        redirect_to backend_inventory_pool_models_path(current_inventory_pool)
      else 
        redirect_to :action => 'new', :original_id => @item.id  
      end
    else
      flash[:error] = @item.errors.full_messages
      render :action => 'show'
    end
  end

  
  def show
    if @item.nil?
      flash[:error] = _("You don't have access to this item.")
      redirect_to backend_inventory_pool_items_path(current_inventory_pool)
    else
      get_histories
    end
  end

#################################################################

=begin #old leihs??# FIXME problem with put request (it catches from the update method)
  def location
    if request.post? or request.put?
      if @item.update_attributes(:location => Location.find_or_create(params[:location]))
        flash[:notice] = _("Location successfully set")
      else
        flash[:error] = _("Error setting the location")
      end
    end
    @item.location ||= Location.new
  end
=end

#################################################################

  def status
  end

#################################################################

  def toggle_permission
    if request.post?
      @item.needs_permission = (not @item.needs_permission?)
      @item.save
    end
    redirect_to :action => 'show', :id => @item.id
  end

=begin # TODO merge to update ??
  def retire
    if request.post?
      # NOTE since it's a switch form, the hidden param ensures the correct action
      if @item.retired and !params[:retired].blank?
        @item.retired = nil
      else
        @item.retired = Date.today
      end
      @item.retired_reason = params[:reason]
      if @item.save
        msg = _("Item retired (%s)") % @item.retired_reason
        @item.log_history(msg, current_user)
        flash[:notice] = msg
        redirect_to params[:source_path] and return
      else
        flash[:error] = @item.errors.full_messages
      end
    end
    
    params[:layout] = "modal" #old??#
    render :action => 'retire'
  end
=end
  
#################################################################

  def notes
    if request.post?
      @item.log_history(params[:note], current_user.id)
    end
    @histories = @item.histories

    get_histories
    
    params[:layout] = "modal" #old??#
  end

  def get_notes
    get_histories
    render :partial => 'notes', :object => @histories
  end
  
  def supplier
    if request.post? and params[:supplier]
      s = Supplier.create(params[:supplier])
      search_term = s.name
    end
    if request.post? and (params[:search] || search_term)
      search_term ||= params[:search][:name]
      @results = Supplier.where(['name like ?', "%#{search_term}%"]).order(:name)
    end
    render :layout => false
  end

  def inventory_codes
    @free_ranges = Item.free_inventory_code_ranges(params)
  end
  
#################################################################


  private

  def get_histories
    @histories = @item.histories
    @item.contract_lines.collect(&:contract).uniq.each do |contract|
      @histories += contract.actions
    end
    @item.contract_lines.each do |cl|
      @histories << History.new(:created_at => cl.start_date, :user => cl.contract.user, :text => _("Item handed over as part of contract %d.") % cl.contract.id) if cl.start_date
      @histories << History.new(:created_at => cl.end_date, :user => cl.contract.user, :text => _("Expected to be returned.")) unless cl.returned_date
    end
    @histories.sort!
  end
  
end
