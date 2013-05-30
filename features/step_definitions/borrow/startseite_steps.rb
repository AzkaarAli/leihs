# encoding: utf-8

Dann(/^befindet man sich auf der Startseite$/) do
  current_path.should eq borrow_start_path
end

Dann(/^man sieht genau die für den Usern bestimmte t\-Kategorien mit Bild und Namen$/) do
  @main_categories = current_user.categories.select {|c| c.parents.empty?}
  all("a", text: mc.name).size.should eq @main_categories.size
end

Dann(/^man sieht die Überschrift "(.*?)"$/) do |arg1|
  pending # express the regexp above with the code you wish you had
end
