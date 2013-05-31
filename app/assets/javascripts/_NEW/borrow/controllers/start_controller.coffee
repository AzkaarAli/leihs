class window.App.Borrow.StartController extends Spine.Controller

  events:
    "mouseenter [data-category_id]": "fetchChildren"

  delegateEvents: ->
    super
    App.Category.bind "refresh", @renderCategories

  fetchChildren: (e)->
    category = App.Category.find_or_build
      id: $(e.currentTarget).data("category_id")
    App.Category.fetch
      data: $.param
        category_id: category.id
        children: true

  renderCategories: ->
    console.log @el