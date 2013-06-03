# encoding: utf-8

Dann(/^seh ich die Navigation auf jeder Seite$/) do
  find("nav")
end

Dann(/^die Navigation beinhaltet Ausleihen, Geräteparks, Benutzer und Logout$/) do
  find("nav [href='#{borrow_inventory_pools_path}']", :text => _("InventoryPools"))
  find("nav [href='#{borrow_user_path}']", :text => @current_user.name)
  find("nav [href='#{logout_path}']", :text => _("Logout"), :visible => false)
end

Dann(/^die Navigation beinhaltet Backend, Geräteparks, Benutzer und Logout$/) do
  step 'die Navigation beinhaltet Geräteparks, Benutzer und Logout'
  binding.pry
end

Dann(/^seh ich in der Navigation den Home\-Button$/) do
  binding.pry
end

Wenn(/^ich den Home\-Button bediene$/) do
  pending
end

Dann(/^lande ich auf der Seite der Hauptkategorien$/) do
  pending
end