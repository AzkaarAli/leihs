class Backend::UsersController < Backend::BackendController

  before_filter do
    params[:id] ||= params[:user_id] if params[:user_id]
#    @user = current_inventory_pool.users.find(params[:id]) if params[:id]
    @user = User.find(params[:id]) if params[:id]

    authorized_admin_user? unless current_inventory_pool  
  end

######################################################################

  def index
  end

  def show
  end
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(params[:user])
    @user.login = @user.email
    if @user.save
      @user.access_rights.create(:inventory_pool => current_inventory_pool,
                                 :role => Role.where(:name => "customer").first) if current_inventory_pool
      redirect_to [:backend, current_inventory_pool, @user].compact
    else
      flash[:error] = @user.errors.full_messages
      render :action => :new
    end
  end

  def edit
  end
  
  def update
    if @user.update_attributes(params[:user])
      flash[:notice] = _("User details were updated successfully.")
      redirect_to [:backend, current_inventory_pool, @user].compact
    else
      flash[:error] = _("The new user details could not be saved.")
      redirect_to [:edit, :backend, current_inventory_pool, @user].compact
    end
  end
  
  def set_start_screen(path = params[:path])
    if current_user.start_screen(current_inventory_pool,path)
      render :nothing => true, :status => :ok
    else
      render :nothing => true, :status => :bad_request 
    end
  end
  
#################################################################

  # OPTIMIZE
  def things_to_return
    @user_things_to_return = @user.things_to_return
  end

  def extended_info
  end

  def groups
  end
  
  def add_group(group = params[:group])
    @group = current_inventory_pool.groups.find(group[:group_id])
    unless @user.groups.include? @group
      @user.groups << @group
      @user.save!
    end
    redirect_to :action => 'groups'
  end

  def remove_group(group_id = params[:group_id])
    @group = current_inventory_pool.groups.find(group_id)
    if @user.groups.include? @group
      @user.groups.delete @group
      @user.save!
    end
    redirect_to :action => 'groups'
  end

  def remind
    if @user.remind(current_user)
      respond_to do |format|
        format.json { render :json => true, :status => 200 }
      end
    else
      respond_to do |format|
        format.json { render :text => @user.errors, :status => 500 }
      end
    end
  end
  
  def new_contract
    redirect_to [:backend, current_inventory_pool, @user, :hand_over]
  end

#################################################################

  def access_rights
    @access_rights = if current_inventory_pool
                        @user.access_rights.scoped_by_inventory_pool_id(current_inventory_pool)
                      else
                        @user.access_rights.includes(:inventory_pool).order("inventory_pools.name")
                      end
  end
  
  def add_access_right
    inventory_pool_id = if current_inventory_pool
                          current_inventory_pool.id
                        else
                          params[:access_right][:inventory_pool_id]
                        end
    
    r = Role.find(params[:access_right][:role_id]) if params[:access_right]
    r ||= Role.find_by_name("customer") # OPTIMIZE
  
    ar = @user.all_access_rights.where(:inventory_pool_id => inventory_pool_id).first
   
    if ar
      ar.update_attributes(:role => r, :access_level => params[:access_level])
      ar.update_attributes(:deleted_at => nil) if ar.deleted_at
      flash[:notice] = _("Access Right successfully updated")
    else
      ar = @user.access_rights.create(:role => r, :inventory_pool_id => inventory_pool_id, :access_level => params[:access_level])
      flash[:notice] = _("Access Right successfully created")
    end

    unless ar.valid?
      flash[:notice] = nil
      flash[:error] = ar.errors.full_messages
    end
    redirect_to url_for([:access_rights, :backend, current_inventory_pool, @user].compact)
  end

  def remove_access_right
    ar = @user.access_rights.find(params[:access_right_id])
    if ar.inventory_pool_id.nil? or ar.inventory_pool.contract_lines.by_user(@user).to_take_back.empty?
      ar.deactivate
    else
      flash[:error] = _("Currently has things to return")
    end
    redirect_to url_for([:access_rights, :backend, current_inventory_pool, @user].compact)
  end

  def suspend_access_right
    ar = @user.access_rights.find(params[:access_right_id])
    ar.update_attributes(:suspended_until => Date.parse(params[:suspended_until]))
    ar.histories.create(:text => params[:reason], :user_id => current_user, :type_const => History::CHANGE)
    redirect_to url_for([:access_rights, :backend, current_inventory_pool, @user].compact)
  end

  def reinstate_access_right
    ar = @user.access_rights.find(params[:access_right_id])
    ar.update_attributes(:suspended_until => Date.yesterday)
    ar.histories.create(:text => _("Access right reinstated"), :user_id => current_user, :type_const => History::CHANGE)
    redirect_to url_for([:access_rights, :backend, current_inventory_pool, @user].compact)
  end

  def update_badge_id
    @user.update_attributes(:badge_id => params[:badge_id])
    
    # OPTIMIZE rebuild index for related orders and contracts
    @user.documents.each {|d| d.save }
    flash[:notice] = _("Badge ID was updated")

    render :update do |page|
                    page.replace "badge_id_form", :partial => "badge_id_form", :locals => { :user => @user }
                    page.replace_html 'flash', flash_content
                    flash.discard
                  end
  end

end
