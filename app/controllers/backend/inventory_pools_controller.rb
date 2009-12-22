class Backend::InventoryPoolsController < Backend::BackendController
    
  def index
    if is_admin?
      @inventory_pools = InventoryPool.all
    else
      @inventory_pools = current_user.inventory_pools.select {|ip| current_user.has_role?('lending manager', ip, false) }.compact
      redirect_to backend_inventory_pool_path(@inventory_pools.first) if @inventory_pools.size == 1
    end
  end

  def info
    
  end
  
  def show
  end
  
  def new
    @inventory_pool = InventoryPool.new
    render :action => 'edit'
  end

  def create
    @inventory_pool = InventoryPool.new
    update
    current_user.access_rights.create(:role => Role.first(:conditions => {:name => 'inventory manager' }),
                                      :inventory_pool => @inventory_pool,
                                      :access_level => 3,
                                      :level => 1) unless @inventory_pool.new_record?
  end

  def update
    @inventory_pool ||= @inventory_pool = InventoryPool.find(params[:id]) 
    if @inventory_pool.update_attributes(params[:inventory_pool])
      redirect_to backend_inventory_pool_path(@inventory_pool)
    else
      render :action => 'show' # TODO 24** redirect to the correct tabbed form
    end
  end

  def destroy
    @inventory_pool = InventoryPool.find(params[:id]) 

    if @inventory_pool.items.empty?
      
      @inventory_pool.destroy
      respond_to do |format|
        format.html { redirect_to backend_inventory_pools_path }
        format.js {
          render :update do |page|
            page.visual_effect :fade, "inventory_pool_#{@inventory_pool.id}" 
          end
        }
      end
    else
      # TODO 0607 ajax delete
      @inventory_pool.errors.add_to_base _("The Inventory Pool must be empty")
      render :action => 'show' # TODO 24** redirect to the correct tabbed form
    end
  end


end
