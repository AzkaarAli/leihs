window.Libraries ?= {}
class window.Libraries.TopBarSearchItem

  constructor: (options)->
    @el = options.el
    @input = @el.find "input[type='text']"
    do @delegateEvents

  delegateEvents: =>
    @input.on "focus", => @el.addClass("active")
    @input.on "blur", => @el.removeClass("active")