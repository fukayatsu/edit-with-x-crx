getPosition = (elem) ->
  lines = elem.value.substr(0, elem.selectionStart).split("\n")
  line  = lines.length
  col   = lines[line - 1].length
  [line, col]

initWS = ($textarea, pos, setting) ->
  address = "ws://0.0.0.0:#{setting.port || 51234}"
  ws = new WebSocket(address);

  ws.onerror = () ->
    alert("server is not running on #{address} ?")

  ws.onopen = () ->
    data = {
      method:  'init',
      text:    $textarea.val(),
      line:    pos[0],
      col:     pos[1],
      editor:  setting.editor,
      command: setting.command,
      ext:     setting.ext
    }

    console.log(data) if setting.debug
    ws.send(JSON.stringify(data))

  ws.onmessage = (event) ->
    data = JSON.parse(event.data)
    console.log(data) if setting.debug

    switch data.method
      when 'inited'
        $textarea.data('background-color', $textarea.css('background-color'))
        $textarea.css('background-color', setting.color || '#4169e1')
        ws.send(JSON.stringify({
          method: 'watch',
          pid:      data.pid
          tempfile: data.tempfile,
        }))
      when 'watched'
        $textarea.val(data.text) if data.text

        setTimeout ->
          if ws.readyState == ws.OPEN
            ws.send JSON.stringify
              method: 'watch',
              pid: data.pid,
              tempfile: data.tempfile
          else
            # finish editing
            chrome.extension.sendRequest { method: "activateTab" }, ->
              setTimeout ->
                $textarea.css('background-color', $textarea.data('background-color'))
              , 500
        , setting.interval || 1000


$(document).on 'dblclick', 'textarea', ->
  that = this
  chrome.extension.sendRequest { method: "getSetting" }, (response) ->
    setting = response.data
    return unless setting.dblclick
    initWS $(that), getPosition(that), setting if setting.double_click

$(document).on 'keydown', 'textarea', (e) ->
  that = this
  chrome.extension.sendRequest { method: "getSetting" }, (response) ->
    setting = response.data
    return unless setting.shortcut && eval(setting.shortcut)
    e.preventDefault()
    initWS $(that), getPosition(that), setting if setting.shortcut
