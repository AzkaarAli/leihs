# encoding: utf-8

Dann(/^sieht man auf jeder Seite das Suchfeld$/) do
  visit borrow_start_path
  find(".topbar").find(".topbar-search")
end
