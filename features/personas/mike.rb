# coding: UTF-8

# Persona:  Mike
# Job:      Inventory Manager
#

module Persona
  
  class Mike
    
    @@name = "Mike"
    @@lastname = "H."
    @@password = "password"
    @@email = "mike@zhdk.ch"
    @@inventory_pool_name = "A-Ausleihe"
    
    def initialize
      setup_dependencies
      
      ActiveRecord::Base.transaction do 
        create_inventory_manager_user
        create_location_and_building
        create_groups
        create_minimal_inventory
        create_holidays
      end
    end
    
    def setup_dependencies 
      Persona.create :ramon
      Persona.create :matti
    end
    
    def create_inventory_manager_user
      @user = FactoryGirl.create(:user, :firstname => @@name, :lastname => @@lastname, :login => @@name.downcase, :email => @@email)
      @inventory_pool = InventoryPool.find_by_name(@@inventory_pool_name)
      @user.access_rights.create(:role => Role.find_by_name("manager"), :inventory_pool => @inventory_pool, :access_level => 3)
      @database_authentication = FactoryGirl.create(:database_authentication, :user => @user, :password => @@password)
    end
    
    def create_location_and_building
      @building = FactoryGirl.create(:building, :name => "Ausstellungsstrasse 60", :code => "AU60")
      @location = FactoryGirl.create(:location, :room => "UG 13", :shelf => "Ausgabe", :building => @building)
    end
    
    def create_groups
      @group_cast = FactoryGirl.create(:group, :name => "Cast", :inventory_pool => @inventory_pool)
      @group_iad = FactoryGirl.create(:group, :name => "IAD", :inventory_pool => @inventory_pool)
    end

    def create_minimal_inventory
      
      setup_sharp_beamers
      setup_cameras
      
      setup_tripods
      setup_options
      
      setup_templates
      setup_package
      
      setup_not_borrowable
      setup_retired
      setup_broken
      setup_incomplete
      
      setup_inventory_moved_to_other_responsible
      setup_inventory_for_group_cast
    end
    
    def setup_sharp_beamers
      @beamer_category = FactoryGirl.create(:category, :name => "Beamer")
      @beamer_model = FactoryGirl.create(:model, :name => "Sharp Beamer",
                                :manufacturer => "Sharp", 
                                :description => "Beamer, geeignet für alle Verwendungszwecke.", 
                                :hand_over_note => "Beamer brauch ein VGA Kabel!", 
                                :maintenance_period => 0)
      @beamer_model.model_links.create :model_group => @beamer_category
      @beamer_item = FactoryGirl.create(:item, :inventory_code => "beam123", :serial_number => "xyz456", :model => @beamer_model, :location => @location, :owner => @inventory_pool)
      @beamer_item2 = FactoryGirl.create(:item, :inventory_code => "beam345", :serial_number => "xyz890", :model => @beamer_model, :location => @location, :owner => @inventory_pool)
    end
    
    def setup_cameras
      @camera_category = FactoryGirl.create(:category, :name => "Kameras")
      @camera_model = FactoryGirl.create(:model, :name => "Kamera Nikon X12",
                                :manufacturer => "Nikon", 
                                :description => "Super Kamera.", 
                                :hand_over_note => "Kamera brauch Akkus!", 
                                :maintenance_period => 0)
      @camera_model.model_links.create :model_group => @camera_category
      @camera_item = FactoryGirl.create(:item, :inventory_code => "cam123", :serial_number => "abc234", :model => @camera_model, :location => @location, :owner => @inventory_pool)
      @camera_item2= FactoryGirl.create(:item, :inventory_code => "cam345", :serial_number => "ab567", :model => @camera_model, :location => @location, :owner => @inventory_pool)
      @camera_item3= FactoryGirl.create(:item, :inventory_code => "cam567", :serial_number => "ab789", :model => @camera_model, :location => @location, :owner => @inventory_pool)
      @camera_item4= FactoryGirl.create(:item, :inventory_code => "cam53267", :serial_number => "ab782129", :model => @camera_model, :location => @location, :owner => @inventory_pool)
      @camera_item5= FactoryGirl.create(:item, :inventory_code => "cam532asd67", :serial_number => "ab78as2129", :model => @camera_model, :location => @location, :owner => @inventory_pool)
    end
    
    def setup_tripods
      @tripod_category = FactoryGirl.create(:category, :name => "Stative")
      @tripod_model = FactoryGirl.create(:model, :name => "Kamera Stativ",
                                :manufacturer => "Feli", 
                                :description => "Stabiles Kamera Stativ", 
                                :hand_over_note => "Stativ muss mit Stativtasche ausgehändigt werden.",
                                :maintenance_period => 0)
      @tripod_model.model_links.create :model_group => @tripod_category
      @tripod_item = FactoryGirl.create(:item, :inventory_code => "tri789", :serial_number => "fgh567", :model => @tripod_model, :location => @location, :owner => @inventory_pool)
      @tripod_item2 = FactoryGirl.create(:item, :inventory_code => "tri123", :serial_number => "fgh987", :model => @tripod_model, :location => @location, :owner => @inventory_pool)
      @tripod_item3 = FactoryGirl.create(:item, :inventory_code => "tri923", :serial_number => "asd213", :model => @tripod_model, :location => @location, :owner => @inventory_pool)
      @tripod_item4 = FactoryGirl.create(:item, :inventory_code => "tri212", :serial_number => "tri212", :model => @tripod_model, :location => @location, :owner => @inventory_pool)
    end
    
    def setup_options
      @akku_aa = FactoryGirl.create(:option, :name => "Akku AA",
                                             :inventory_pool => @inventory_pool,
                                             :inventory_code => "akku-aa")      
      @akku_aaa = FactoryGirl.create(:option, :name => "Akku AAA",
                                             :inventory_pool => @inventory_pool,
                                             :inventory_code => "akku-aaa")      
      @usb_cable = FactoryGirl.create(:option, :name => "USB Kabel",
                                             :inventory_pool => @inventory_pool,
                                             :inventory_code => "usb")      
    end
    
    def setup_templates
      @camera_tripod_template = FactoryGirl.create(:template, :name => "Kamera & Stativ")
      @camera_tripod_template.inventory_pools << @inventory_pool
      FactoryGirl.create(:model_link, :model_group => @camera_tripod_template, :model => @camera_model, :quantity => 1)      
      FactoryGirl.create(:model_link, :model_group => @camera_tripod_template, :model => @tripod_model, :quantity => 1)      
    end   
    
    def setup_package
      @camera_package = FactoryGirl.create(:package_with_items, :inventory_pool => @inventory_pool, :name => "Kamera Set")
    end
    
    def setup_not_borrowable
      # canon
      @canon_d5 = FactoryGirl.create(:model, :name => "Kamera Canon D5",
                                :manufacturer => "Canon", 
                                :description => "Ganz teure Kamera", 
                                :hand_over_note => "Kamera brauch Akkus!", 
                                :maintenance_period => 0)
      @canon_d5.model_links.create :model_group => @camera_category
      @canon_d5_item = FactoryGirl.create(:item, :inventory_code => "cand5", :is_borrowable => false, :serial_number => "cand5", :model => @camera_model, :location => @location, :owner => @inventory_pool)

      # beamer
      @not_borrowable_beamer = FactoryGirl.create(:item, :inventory_code => "beam21231", :is_borrowable => false, :serial_number => "beamas12312", :model => @beamer_model, :location => @location, :owner => @inventory_pool)
    end
    
    def setup_broken
      @windows_laptop_model = FactoryGirl.create(:model, :name => "Windows Laptop",
                                :manufacturer => "Microsoft", 
                                :description => "Ein Laptop der Marke Microsoft", 
                                :hand_over_note => "Laptop mit Tasche ausgeben", 
                                :maintenance_period => 0)
      @notebook_category = FactoryGirl.create(:category, :name => "Notebooks")
      @windows_laptop_model.model_links.create :model_group => @notebook_category
      @windows_laptop_item = FactoryGirl.create(:item, :inventory_code => "wlaptop1", :is_broken => true, :serial_number => "wlaptop1", :model => @windows_laptop_model, :location => @location, :owner => @inventory_pool)
    end

    def setup_incomplete
      @helicopter_model = FactoryGirl.create(:model, :name => "Walkera v120",
                                :manufacturer => "Walkera", 
                                :description => "3D Helikopter", 
                                :maintenance_period => 0)
      @helicopter_category = FactoryGirl.create(:category, :name => "RC Helikopter")
      @helicopter_model.model_links.create :model_group => @helicopter_category
      @helicopter_item = FactoryGirl.create(:item, :inventory_code => "v120d02", :is_incomplete => true, :serial_number => "v120d02", :model => @helicopter_model, :location => @location, :owner => @inventory_pool)
    end

    def setup_retired
      @iMac = FactoryGirl.create(:model, :name => "iMac",
                                :manufacturer => "Apple", 
                                :description => "Apples alter iMac", 
                                :maintenance_period => 0)
      @computer_category = FactoryGirl.create(:category, :name => "Computer")
      @iMac.model_links.create :model_group => @computer_category
      @iMac = FactoryGirl.create(:item, :inventory_code => "iMac1", :retired => Date.today, :is_borrowable => true, :serial_number => "iMac5", :model => @iMac, :location => @location, :owner => @inventory_pool)
    end
    
    def setup_inventory_moved_to_other_responsible
      @beamer_for_it = FactoryGirl.create(:item, :inventory_code => "beam897", :inventory_pool_id => InventoryPool.find_by_name("IT-Ausleihe").id, :serial_number => "xyz890", :model => @beamer_model, :location => @location, :owner => @inventory_pool)    
    end

    def setup_inventory_for_group_cast
      Partition.create({:model => @camera_model, :inventory_pool => @inventory_pool, :group => @group_cast, :quantity => 1})
      Partition.create({:model => @camera_model, :inventory_pool => @inventory_pool, :group => @group_iad, :quantity => 1})
    end

    def create_holidays
      next_christmas = (Date.today().month == 12 and Date.today().day > 23)? Date.new(Date.today().year+1.day, 12, 24) : Date.new(Date.today().year, 12, 24)
      Holiday.create({:inventory_pool_id => @inventory_pool.id, :start_date => next_christmas, :end_date => next_christmas, :name => "Christmas"})
    end
  end  
end
