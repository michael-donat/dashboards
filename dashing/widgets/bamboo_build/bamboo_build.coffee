class Dashing.BambooBuild extends Dashing.Widget
  @accessor 'value', Dashing.AnimatedValue

  constructor: ->
    super

  refreshWidgetState: =>
    node = $(@node)
    node.removeClass('successful failed unknown')
    node.addClass(@get('state').toLowerCase())
    link = $(@node).find("a")
    link.attr('href', @get('link'))
    link.attr('target', @get('target'))

  ready: ->
    @refreshWidgetState()

  onData: (data) ->
    @refreshWidgetState()