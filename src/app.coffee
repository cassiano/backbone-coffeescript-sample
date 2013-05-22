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
      index: 999
      
    greeting: -> "#{@get 'part1'}, #{@get 'part2'} (#{@get 'index'})!"
    
    swap: ->
      @set
        part1: @get 'part2'
        part2: @get 'part1'
    
  App.Views.ItemView = class extends Backbone.View
    tagName: 'li'
    
    template: _.template $('#item-view-template').html()
    
    initialize: ->
      _.bindAll @
      
      @listenTo @model, 'change', @render
      @listenTo @model, 'remove', @unrender
    
    render: ->
      $(@el).html @template(model: @model)
      @
      
    unrender: -> $(@el).remove()

    swap: -> 
      @model.swap()
      @model.save()

    remove: -> @model.destroy()

    events:
      'click .swap': 'swap'
      'click .delete': 'remove'

  App.Collections.List = class extends Backbone.Collection
    model: App.Models.Item
    
    localStorage: new Backbone.LocalStorage('backbone+coffeescript')

  App.Views.ListView = class extends Backbone.View
    el: $ 'body'
    
    initialize: ->
      _.bindAll @
      
      @collection = new App.Collections.List
      @listenTo @collection, 'add', @appendItem
            
      @counter = 0
      @render()

      @collection.fetch remove: false   # 'remove: false' assures an "add" event is sent for every new model.

    render: ->
      $(@el).append $('#list-view-template').html()
      @
      
    addItem: ->
      @counter++
      
      # item = new App.Models.Item
      # item.set part2: "#{item.get 'part2'} #{@counter}"
      # @collection.add item
      # item.save()

      @collection.create index: @counter
      
    appendItem: (item) ->
      item_view = new App.Views.ItemView model: item
      $('ul').append item_view.render().el

      # Keep track of the largest counter.
      index = item.get('index')
      @counter = index if index > @counter
            
    events: 'click button': 'addItem'

  # Backbone.sync = (method, model, success, error) ->
  #   console.log "Performing action '#{method}' in #{model.greeting()}..."
  #   success?()
      
  App.start()
