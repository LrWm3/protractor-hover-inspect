injected = injected or do ->
  
  enabled = false

  class TinyInspect

    createNodes: ->
      do appendOverlay = =>
        $overlay = document.createElement 'div'
        $overlay.classList.add 'tl-overlay'

        document.body.appendChild $overlay

      do appendLogger = =>
        $logg = document.createElement 'div'
        $logg.classList.add 'tl-loggerWrap'

        $code = document.createElement 'code'
        $code.classList.add 'language-markup'
        $code.appendChild document.createTextNode '<html>'
        $logg.appendChild $code

        document.body.appendChild $logg


      @$overlay = document.querySelector '.tl-overlay'
      @$wrap = document.querySelector '.tl-loggerWrap'
      @$code = document.querySelector '.tl-loggerWrap code'

    destroy: ->
      @$wrap.classList.add '-out'
      document.removeEventListener 'mousemove', @logg
      @$overlay.outerHTML = ''
      setTimeout =>
        @$wrap.outerHTML = ''
      , 600

    registerEvents: ->
      @highlight()
      document.addEventListener 'mousemove', @logg

    logg: (e)=>
      $target = e.target
      targetRect = $target.getBoundingClientRect()
      overlayStyleString = "
        width: #{targetRect.width}px;
        height: #{targetRect.height}px;
        top: #{targetRect.top + window.pageYOffset}px;
        left: #{targetRect.left + window.pageXOffset}px;
        "
      @$overlay.style.cssText = overlayStyleString

      $clone = $target.cloneNode()

      serializer  = new XMLSerializer()
      stringified = serializer.serializeToString $clone
      stringified = stringified
        .slice 0, stringified.indexOf('>')+1
        .replace ' xmlns="http://www.w3.org/1999/xhtml"', ''

      @$code.innerText = stringified
      @highlight()

    highlight: =>
      Prism.highlightElement @$code



  inspector = new TinyInspect()

  chrome.runtime.onMessage.addListener (request, sender, sendResponse)->
    enabled = !enabled
    if enabled
      inspector.createNodes()
      inspector.registerEvents()
    else
      inspector.destroy()

  return true




