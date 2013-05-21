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
		
		initialize: ->
			_.bindAll @
			
			# @model.bind 'change', @render
			# @model.bind 'remove', @unrender
			@listenTo @model, 'change', @render
			@listenTo @model, 'remove', @unrender
		
		render: ->
			$(@el).html """
				<span>#{@model.greeting()}</span>
				<span class="swap">[Swap]</span>
				<span class="delete">[Delete]</span>
				"""
			@
			
		unrender: -> $(@el).remove()

		swap: -> @model.swap()

		remove: -> @model.destroy()

		events:
			'click .swap': 'swap'
			'click .delete': 'remove'

	App.Collections.List = class extends Backbone.Collection
		model: App.Models.Item

		# localStorage: new Backbone.LocalStorage('backbone+coffeescript')

	App.Views.ListView = class extends Backbone.View
		el: $ 'body'
		
		initialize: ->
			_.bindAll @
			
			@collection = new App.Collections.List
			# @collection.bind 'add', @appendItem
			@listenTo @collection, 'add', @appendItem
						
			@counter = 0
			@render()
			
		render: ->
			$(@el).append '<button>Add Item</button>'
			$(@el).append '<ul></ul>'
			@
			
		addItem: ->
			@counter++
			
			item = new App.Models.Item
			item.set part2: "#{item.get 'part2'} #{@counter}"
			# item.save()
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
