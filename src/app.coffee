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
			
		greeting: -> "#{@get 'part1'}, #{@get 'part2'}!"
		
		swap: ->
			@set
				part1: @get 'part2'
				part2: @get 'part1'
		
	App.Views.ItemView = class extends Backbone.View
		tagName: 'li'
		
		template: _.template $('#item-view-template').html()
		
		initialize: ->
			_.bindAll @
			
			@listenTo @model, 'change', @render				# @model.on 'change', @render
			@listenTo @model, 'remove', @unrender			# @model.on 'remove', @unrender
		
		render: ->
			$(@el).html @template(model: @model)
			@
			
		unrender: -> $(@el).remove()

		swap: -> @model.swap()

		remove: -> @model.destroy()

		events:
			'click .swap': 'swap'
			'click .delete': 'remove'

	App.Collections.List = class extends Backbone.Collection
		model: App.Models.Item

	App.Views.ListView = class extends Backbone.View
		el: $ 'body'
		
		initialize: ->
			_.bindAll @
			
			@collection = new App.Collections.List
			@listenTo @collection, 'add', @appendItem		# @collection.on 'add', @appendItem
						
			@counter = 0
			@render()
			
		render: ->
			$(@el).append $('#list-view-template').html()
			@
			
		addItem: ->
			@counter++
			
			item = new App.Models.Item
			item.set part2: "#{item.get 'part2'} #{@counter}"
			@collection.add item
			
			# @collection.create part2: "#{(new App.Models.Item).get 'part2'} #{@counter}"
			
		appendItem: (item) ->
			item_view = new App.Views.ItemView model: item
			$('ul').append item_view.render().el
			
		events: 'click button': 'addItem'

	# Backbone.sync = (method, model, success, error) ->
	#		alert "Performing action '#{method}' in #{model.greeting()}..."
	#		success?()
			
	App.start()
