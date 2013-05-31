###
  
  Category

###

class Category extends Spine.Model

  @configure "Category", "id", "user_id"

  @extend Spine.Model.Ajax
  @extend App.Modules.FindOrBuild
  @include App.Modules.HasLines

  @belongsTo "user", "App.User"
  @hasMany "lines", "App.OrderLine", "order_id"

  approve: -> 
    $.post "/backend/ip/#{App.InventoryPool.current.id}/orders/#{@id}/approve"

  reject: (comment)->
    $.post "/backend/ip/#{App.InventoryPool.current.id}/orders/#{@id}/reject", {comment: comment}

window.App.Order = Order