###
  
  Category

###

class Category extends Spine.Model

  @configure "Category", "id", "name"
  
  @extend Spine.Model.Ajax
  @extend App.Modules.FindOrBuild

  @url: => "categories"

window.App.Category = Category