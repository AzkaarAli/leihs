class Backend::TemporaryController < Backend::BackendController
  require_role "inventory_manager", :for_all_except => :create_some
  
  def create_some
    reset_session
    clean_db_and_index
    
    params[:id] = 3
    params[:name] = "model"
    if params[:all]
      max = params[:all].to_i
      if max > 0
        Importer.new.start(max)
      else
        Importer.new.start
      end
    else
      create_meaningful_inventory
    end
    
    params[:id] = 5
    params[:name] = "user"
    create_some_users
    create_meaningful_users

    params[:id] = 10
    create_some_new_orders
    create_beautiful_order

    render :text => "Complete"
  end
  
private
  
#  def create_some_inventory
#    params[:id].to_i.times do |i|
#      m = Model.new(:name => params[:name] + " " + i.to_s)
#      m.save
#      5.times do |serial_nr|
#        i = Item.new(:model_id => m.id, :inventory_code => Item.get_new_unique_inventory_code)
#      
#        i.save
#      end
#    end
#  end

  def create_some_users
    params[:id].to_i.times do |i|
      u = User.new(:login => "#{params[:name]}_#{i}")
        #u.roles << Role.find(:first, :conditions => {:name => "inventory_manager"})
        r = Role.find(:first, :conditions => {:name => "inventory_manager"})
        i = InventoryPool.find(:first)
        u.access_rights << AccessRight.new(:role => r, :inventory_pool => i)
      u.save
    end
  end

  def create_some_new_orders
    users = User.find(:all)
    models = Model.find(:all)
    params[:id].to_i.times do |i|
      order = Order.new()
      order.user_id = users[rand(users.size)].id
      3.times {
        d = Array.new
        2.times { d << Date.new(rand(2)+2008, rand(12)+1, rand(28)+1) }
        start_date = d.min 
        end_date = d.max
        order.add_line(rand(3), models[rand(models.size)], order.user_id, start_date, end_date )
      }
      order.purpose = "This is the purpose: text text and more text, text text and more text, text text and more text, text text and more text."
      order.save
    end
  end
  
    
  def create_meaningful_users
    users = ['Ramon Cahenzli', 'Jerome Müller', 'Franco Sellitto']
    users.each do |u|
      u = User.new(:login => u.to_s)
      u.save
    end
  end
  
  def create_meaningful_inventory
    stuff = ['Beamer NEC LT 245', 'Beamer Davis 1650', 'Kamera Nikon D80', 'Stativ Manfrotto 390', 'Brillenputzuch', 'Laserschwert']

    stuff.each do |st|
      m = Model.new(:name => st )
      m.save
      2.times do |serial_nr|
        i = Item.new(:model_id => m.id, :inventory_code => Item.get_new_unique_inventory_code )
        i.save
      end
    end
  end
  
  def create_beautiful_order
    m = Model.find(:first)
  
    
    order = Order.new()
    order.user_id = User.find_by_login("Ramon Cahenzli")
    order.add_line(3, m, order.user_id, Date.new(2008, 10, 12), Date.new(2008, 10, 20))
    order.purpose = "This is the purpose: text text and more text, text text and more text, text text and more text, text text and more text."
    order.save
    
    order = Order.new()
    order.user_id = User.find_by_login("Ramon Cahenzli")
    order.add_line(6, m, order.user_id, Date.new(2008, 10, 15), Date.new(2008, 10, 30))
    order.purpose = "This is the purpose: text text and more text, text text and more text, text text and more text, text text and more text."
    order.save
    
    
    order = Order.new()
    order.user_id = User.find_by_login("Ramon Cahenzli")
    order.add_line(1, m, order.user_id, Date.new(2008, 10, 20), Date.new(2008, 10, 30))
    order.purpose = "This is the purpose: text text and more text, text text and more text, text text and more text, text text and more text."
    order.save
    
  end
    
  def clean_db_and_index
    Item.delete_all
    Model.delete_all
    Order.delete_all #destroy_all
    OrderLine.delete_all
    User.delete_all
    Backup::Order.delete_all #destroy_all
    Backup::OrderLine.delete_all
    Contract.delete_all
    ContractLine.delete_all
    Printout.destroy_all
    AccessRight.delete_all
    
    FileUtils.remove_dir(File.dirname(__FILE__) + "/../../../index", true)
  end


end
