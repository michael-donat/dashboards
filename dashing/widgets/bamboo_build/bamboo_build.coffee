class Dashing.BambooBuild extends Dashing.Widget
  @accessor 'value', Dashing.AnimatedValue

  constructor: ->
    super

  refreshWidgetState: =>
    node = $(@node)
    node.removeClass('successful failed unknown building')

    link = $(@node).find("a")
    link.attr('href', @get('link'))
    link.attr('target', @get('target'))

    if @get('building')
      node.addClass('building')
    else
      node.addClass(@get('state').toLowerCase())

  ready: ->
    @refreshWidgetState()

  onData: (data) ->
    @refreshWidgetState()