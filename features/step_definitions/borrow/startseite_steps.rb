# encoding: utf-8

Und(/^man befindet sich auf der Startseite$/) do
  visit borrow_start_path
end

Dann(/^sieht man genau die für den User bestimmte Haupt\-Kategorien mit Bild und Namen$/) do
  @main_categories = @current_user.categories.select {|c| c.parents.empty?}
  categories_counter = 0
  @main_categories.each do |mc|
    find("a", text: mc.name)
    categories_counter += 1
  end
  categories_counter.should eq @main_categories.count
end

Und(/^man sieht die Überschrift "(.*?)"$/) do |arg1|
  find ".row a", text: _("Overview")
end

Wenn(/^ich über eine Hauptkategorie fahre$/) do
  @first_main_category = @main_categories.first
  find("data-category_id='#{@first_main_category.id}'").execute_script("$('.dropdown-holder').trigger('mouseover');")
  step "ensure there are no active requests"
end

Dann(/^sehe ich die Kinder dieser Hauptkategorie$/) do
  second_level_categories = @first_main_category.children
  @second_level_category = second_level_categories.first
  wait_until {find "a", text: @second_level_category.name}
  second_level_categories.each do |c|
    find("a", text: @first_main_category.name).find(".dropdown a", text: c.name)
  end
end

Wenn(/^ich eines dieser Kinder anwähle$/) do
  click_link @second_level_category.name
end

Dann(/^lande ich in der Modellliste für diese Kategorie$/) do
  
end
