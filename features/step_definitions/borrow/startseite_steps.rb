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
