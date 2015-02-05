class Dashing.PullRequests extends Dashing.Widget

  ready: ->
    # This is fired when the widget is done being rendered

  onData: (data) ->
    if data.pulls.length < 2
      wdgClass = 'ok';
    else if data.pulls.length < 4
      wdgClass = 'ehh';
    else
      wdgClass = 'fail';

    node = $(@node)
    node.removeClass('ok ehh fail')
    node.addClass(wdgClass)

    # Handle incoming data
    # You can access the html node of this widget with `@node`
    # Example: $(@node).fadeOut().fadeIn() will make the node flash each time data comes in.