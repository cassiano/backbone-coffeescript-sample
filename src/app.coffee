# To compile automatically, run (from the root folder): "coffee -wc src/*.coffee"

$ ->
  App =
    Models: {}
    Views: {}
    Collections: {}
    start: -> new @Views.ListView
  
  App.Models.Item = class extends Backbone.Model
    defaults:
      part1: 'Hello'
      part2: 'Backbone'
      index: null
      
    greeting: -> "#{@get 'part1'}, #{@get 'part2'} (#{@get 'index'})!"
    
    swap: ->
      @set
        part1: @get 'part2'
        part2: @get 'part1'

      @save()
    
  class App.Views.ItemView extends Backbone.View
    tagName: 'li'
    
    template: _.template $('#item-view-template').html()
    
    initialize: ->
      _.bindAll @
      
      @listenTo @model, 'change', @render
      @listenTo @model, 'destroy', @unrender
    
    render: ->
      $(@el).html @template(model: @model)
      # $(@el).html ecoTemplates['item-view-template.html'](model: @model)
      @
      
    unrender: -> $(@el).remove()

    events:
      # Event   CSS Selector  Method
      # -----   ------------  --------
      'click    .swap':       'swap'
      'click    .remove':     'remove'

    swap:   -> @model.swap()
    remove: -> @model.destroy()

  class App.Collections.List extends Backbone.Collection
    model: App.Models.Item
    
    localStorage: new Backbone.LocalStorage('backbone+coffeescript')
    # url: '/items'

  class App.Views.ListView extends Backbone.View
    el: $ 'body'
    
    initialize: ->
      _.bindAll @
      
      @collection = new App.Collections.List
      @listenTo @collection, 'add', @appendItem
            
      @counter = 0
      @render()

      @collection.fetch remove: false   # The 'remove: false' option assures an 'add' event is sent for every new model added.

    render: ->
      $(@el).append $('#list-view-template').html()
      @
      
    addItem: ->
      @counter++
      
      @collection.create index: @counter

      # Equivalent to:
      # @collection.add(item = new App.Models.Item(index: @counter))
      # item.save()
      
    appendItem: (item) ->
      item_view = new App.Views.ItemView model: item
      $('ul').append item_view.render().el

      # Keep track of the largest counter.
      index = item.get('index')
      @counter = index if index > @counter
            
    events: 'click button': 'addItem'

  App.start()
