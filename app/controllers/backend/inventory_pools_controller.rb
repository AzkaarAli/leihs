class Backend::InventoryPoolsController < Backend::BackendController
    
  def index
    respond_to do |format|
      format.html
    end
  end

  def show(date = params[:date])
    @date = date ? Date.parse(date) : Date.today
    redirect_to backend_inventory_pool_path(current_inventory_pool) if @date < Date.today
        
    today_and_next_4_days = [@date] 
    4.times { today_and_next_4_days << current_inventory_pool.next_open_date(today_and_next_4_days[-1] + 1.day) }
    
    grouped_visits = current_inventory_pool.visits.includes(:user => {}, :contract_lines => [:model, :contract]).where("date <= ?", today_and_next_4_days.last).group_by {|x| [x.action, x.date] }
    
    @chart_data = today_and_next_4_days.map do |day|
      day_name = (day == Date.today) ? _("Today") : l(day, :format => "%a %d.%m")
      take_back_visits_on_day = grouped_visits[["take_back", day]] || []
      take_back_workload = take_back_visits_on_day.size * 4 + take_back_visits_on_day.sum(&:quantity)
      hand_over_visits_on_day = grouped_visits[["hand_over", day]] || []
      hand_over_workload = hand_over_visits_on_day.size * 4 + hand_over_visits_on_day.sum(&:quantity)
      [[take_back_workload, hand_over_workload],
        {:name => day_name,
         :value => "#{take_back_visits_on_day.size+hand_over_visits_on_day.size} Visits<br/>#{take_back_visits_on_day.sum(&:quantity)+hand_over_visits_on_day.sum(&:quantity)} Items"}]
    end

    @orders = current_inventory_pool.orders.submitted.includes(:order_lines => :model, :user => {})
    
    if @date == Date.today
      grouped_visits.keep_if {|k, v| k[1] <= @date }
    else
      grouped_visits.keep_if {|k, v| k[1] == @date }
    end
    @hand_overs = grouped_visits.select {|k, v| k[0] == "hand_over" and k[1] <= @date }.values.flatten
    @take_backs = grouped_visits.select {|k, v| k[0] == "take_back" and k[1] <= @date }.values.flatten
  end
  
  def new
    @inventory_pool = InventoryPool.new
    render :action => 'edit'
  end

  def create
    @inventory_pool = InventoryPool.new
    update
    current_user.access_rights.create(:role => Role.where(:name => 'manager').first,
                                      :inventory_pool => @inventory_pool,
                                      :access_level => 3) unless @inventory_pool.new_record?
  end

  # TODO: this mess needs to be untangled and split up into functions called by new/create/update
  def update
    @inventory_pool ||= @inventory_pool = InventoryPool.find(params[:id]) 
    params[:inventory_pool][:print_contracts] ||= "false" # unchecked checkboxes are *not* being sent
    params[:inventory_pool][:email] = nil if params[:inventory_pool][:email].blank?
    if @inventory_pool.update_attributes(params[:inventory_pool])
      redirect_to backend_inventory_pool_path(@inventory_pool)
    else
      flash[:error] = @inventory_pool.errors.full_messages
      # TODO: set @current_inventory_pool here? See Backend::BackendController#current_inventory_pool
      if action_name == "create"
        render :action => 'edit'
      else
        render :action => 'show' # TODO 24** redirect to the correct tabbed form
      end
    end
  end

  def destroy
    @inventory_pool = InventoryPool.find(params[:id]) 

    if @inventory_pool.items.empty?
      
      @inventory_pool.destroy
      respond_to do |format|
        format.html { redirect_to backend_inventory_pools_path }
      end
    else
      # TODO 0607 ajax delete
      @inventory_pool.errors.add(:base, _("The Inventory Pool must be empty"))
      render :action => 'show' # TODO 24** redirect to the correct tabbed form
    end
  end


end
