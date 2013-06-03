# encoding: utf-8

Angenommen(/^man befindet sich auf irgendeiner Startseite ausser der Bestellübersicht$/) do
  pages_elements = all(".topbar-item-inner").slice 2..4
end

Angenommen(/^man befindet sich auf der Bestellübersicht$/) do
  pending # express the regexp above with the code you wish you had
end

Dann(/^sehe ich kein Bestellfensterchen$/) do
  pending # express the regexp above with the code you wish you had
end
