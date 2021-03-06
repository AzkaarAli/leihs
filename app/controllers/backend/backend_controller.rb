class Backend::BackendController < ApplicationController
  require_role "manager", :for_current_inventory_pool => true
  
  before_filter :init
  
  $general_layout_path = 'layouts/backend/' + $theme + '/general'
  
  layout $general_layout_path
 
###############################################################  
  
  # global search
  def search
# TODO use sphinx_select
#    @result = ThinkingSphinx.search params[:text], { :star => true, :page => params[:page], :per_page => 200,
#                                                     :sort_mode => :extended, :sort_by => "class_crc ASC, @relevance DESC",
##                                                     :group_by => "class_crc",
#                                                     :sphinx_select => "*, inventory_pool_id = #{current_inventory_pool.id} OR owner_id = #{current_inventory_pool.id} AS a",
#                                                     :with => { :a => true } }

    @search = [ { :title => _("Booking"),
                  :color => "#1089D9",
                  :with => { :inventory_pool_id => [current_inventory_pool.id]} },
                { :title => _("Inventory"), # TODO prevent search for Inventory if current_user doesn't have enough permissions
                  :color => "#008209",
                  :with => { :owner_id => [current_inventory_pool.id]} }]

    @search.each do |s|
      s[:result] = ThinkingSphinx.search params[:text], { :star => true, :page => params[:page], :per_page => 999,
                                                          :sort_mode => :extended, :sort_by => "class_crc ASC, @relevance DESC", # :group_by => "class_crc",
                                                          :with => s[:with] }
      
      s[:search] = {}
      s[:result].each do |r|
        res = s[:search][r.class.to_s] || []
        res << r
        s[:search][r.class.to_s] = res
      end
    end
  end

###############################################################  

  def database_backup
    dir = "#{RAILS_ROOT}/db/backups"
    timestamp = Time.now.to_formatted_s(:number)
    src = "#{dir}/#{timestamp}.sql"
    File.open(src, 'w') do |f|
      f << ActiveRecord::Base.connection.structure_dump
      f << ActiveRecord::Base.connection.data_dump
    end
    
    flash[:notice] = _("Database backup successfully done.")
    render :update do |page|
      page.replace_html 'flash', flash_content
      flash.discard
    end
  end

   # add a new line
   def generic_add_line(document, start_date = params[:start_date], end_date = params[:end_date])
    if request.post?
      if params[:model_group_id]
        model = ModelGroup.find(params[:model_group_id]) # TODO scope current_inventory_pool ?
      else
        model = current_inventory_pool.models.find(params[:model_id])
      end
      params[:user_id] = current_user.id
      
      model.add_to_document(document, params[:user_id], params[:quantity], start_date, end_date, current_inventory_pool)

      flash[:notice] = document.errors.full_messages unless document.save
      unless @prevent_redirect # TODO 29**
        redirect_to :action => 'show',
                    :id => document.id
      end
    else
      redirect_to :controller => 'models', 
                  :layout => 'modal',
                  :source_path => request.env['REQUEST_URI'],
                  :start_date => start_date,
                  :end_date => end_date,
                  :user_id => document.user_id
    end
  end


  # swap model for a given line
  def generic_swap_model_line(document)
    if request.post?
      if params[:model_id].nil?
        flash[:notice] = _("Model must be selected")
      else
        document.swap_line(params[:line_id], params[:model_id], current_user.id)
      end
      redirect_to :action => 'show', :id => document.id     
    else
      redirect_to :controller => 'models', 
                  :layout => 'modal',
                  :user_id => document.user_id,
                  :source_path => request.env['REQUEST_URI'],
                  "#{document.class.to_s.underscore}_line_id" => params[:line_id]
    end
  end
  
  # change time frame for OrderLines or ContractLines 
  def generic_time_lines(document, write_start = true, write_end = true)
    @write_start = write_start
    @write_end = write_end

    line_ids = params[:lines].split(',')
    if document.is_a?(User) # NOTE take_back process
      @lines = document.contract_lines.find(line_ids)
    else
      @lines = document.lines.find(line_ids)
    end

    if request.post?
      begin
        start_date = Date.new(params[:line]['start_date(1i)'].to_i, params[:line]['start_date(2i)'].to_i, params[:line]['start_date(3i)'].to_i) if params[:line]['start_date(1i)']
        end_date = Date.new(params[:line]['end_date(1i)'].to_i, params[:line]['end_date(2i)'].to_i, params[:line]['end_date(3i)'].to_i) if params[:line]['end_date(1i)']
        @lines.each {|l| l.document.update_time_line(l.id, start_date, end_date, current_user.id) }
      rescue
      end 
      flash[:error] = []
      @lines.collect(&:document).uniq.each {|doc| flash[:error] += doc.errors.full_messages }
      redirect_to :action => 'show', :id => @lines.first.document.id # NOTE only used for Acknowledge
    else
      params[:layout] = "modal"
      render :template => 'backend/backend/time_lines'
    end   
  end    
  
  # remove OrderLines or ContractLines
  def generic_remove_lines(document)
    if request.delete?
      Model.suspended_delta do
        params[:lines].each {|l| document.remove_line(l, current_user.id) }
      end
      redirect_to :action => 'show', :id => document.id
    else
      @lines = document.lines.find(params[:lines].split(','))
      params[:layout] = "modal"
      render :template => 'backend/backend/remove_lines'
    end   
  end    
###############################################################  

  protected

    helper_method :is_privileged_user?, :is_super_user?, :is_inventory_manager?, :is_lending_manager?, :is_apprentice?, :is_admin?

    # TODO: what's happening here? Explain the goal of this method
    def current_inventory_pool
      return @current_inventory_pool if @current_inventory_pool # OPTIMIZE
      return nil if controller_name == "inventory_pools" and not ["create", "show", "update"].include?(action_name)
      # TODO 28** patch to Rails: actionpack/lib/action_controller/...
      # i.e. /inventory_pools/123 generates automatically params[:inventory_pools_id] additionaly to params[:id]
      if !params[:inventory_pool_id] and params[:id] and controller_name != "users"
        request.path_parameters[:inventory_pool_id] = params[:id]
        request.parameters[:inventory_pool_id] = params[:id]
      end
      return nil if current_user.nil? #fixes http://leihs.hoptoadapp.com/errors/756097 (when a user is not logged in but tries to go to a certain action in an inventory pool (for example when clicking a link in hoptoad)
      @current_inventory_pool ||= current_user.inventory_pools.find(params[:inventory_pool_id]) if params[:inventory_pool_id]
    end

    # helper for respond_to format.js called from derived controllers' indexes
    def search_result_rjs(search_results)
      render :update do |page|
        flash_on_search_result(params[:query], search_results)
        page.replace 'list_table', :partial => 'index' # will render derived controller's partial _index
        page.replace_html 'flash', flash_content
        flash.discard        
      end
    end

    ##################################################
    # ACL
  
    def authorized_admin_user?
      not_authorized! unless is_admin?
    end

    def authorized_privileged_user?
      not_authorized! unless is_privileged_user?
    end
    
    def not_authorized!
        msg = "You don't have appropriate permission to perform this operation."
        respond_to do |format|
          format.html { flash[:error] = msg
                        redirect_to backend_inventory_pools_path
                      } 
          format.js { render :text => msg }
        end
    end
  
    ####### Helper Methods #######

	  def is_admin?
    	#@is_admin ||=
      current_user.has_role?('admin')
  	end

    # Allow operations on items. 'user' is *not* a customer!
    def is_privileged_user?
      #@is_privileged_user ||=
      (has_at_least_access_level(2) and is_owner?)
    end
    
    def is_super_user?
      #@is_super_user ||=
      (is_inventory_manager? and is_owner?)
    end
    
    def is_inventory_manager?
      #@is_inventory_manager ||=
      has_at_least_access_level(3)
    end
    
    def is_lending_manager?(inventory_pool = current_inventory_pool)
      #@is_lending_manager ||= []
      #@is_lending_manager[inventory_pool] ||=
      has_at_least_access_level(2, inventory_pool)
    end
    
    def is_apprentice?(inventory_pool = current_inventory_pool)
      #@is_apprentice ||= []
      #@is_apprentice[inventory_pool] ||=
      has_at_least_access_level(1, inventory_pool)
    end
    

####################################################  
  
  private
  
  def is_owner?
    @item.nil? or (current_inventory_pool.id == @item.owner_id)
  end
  
  def has_at_least_access_level(level, inventory_pool = current_inventory_pool)
    (current_user.has_role?('manager', inventory_pool, false) and current_user.access_level_for(inventory_pool) >= level)
  end
  
  def init
    unless logged_in?
      store_location
      redirect_to :controller => '/session', :action => 'new' and return
    end
  end
  
end
