class StyleguideController < ActionController::Base

  before_filter do
    @sections = {}
    @sections[:general] = Dir.entries(Rails.root.join("app", "views", "styleguide", "general")).reject{|f| f.match(/^_/).nil?}.map{|f| f[/(?<=_)\w*?(?=\.)/]}
  end

end
