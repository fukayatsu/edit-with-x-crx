getPosition = (elem) ->
  lines = elem.value.substr(0, elem.selectionStart).split("\n")
  line  = lines.length
  col   = lines[line - 1].length
  [line, col]

initWS = ($textarea, pos, setting) ->
  url = "ws://0.0.0.0:#{setting.port || 51234}"
  ws = new WebSocket(url);

  ws.onerror = () ->
    alert("server is not running on #{url} ?")

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

initHttp = ($textarea, pos, setting) ->
  url = "http://0.0.0.0:#{setting.port || 51234}"
  $.ajax
    type: "GET"
    url:  url
    error: ->
      alert("server is not running on #{url} ?")
    success: (msg) ->
      return alert("error: server said #{msg}") unless msg == 'ok'

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

      $.ajax
        type: "POST"
        url:  "#{url}/init"
        data: JSON.stringify(data)
        contentType: 'application/json; charset=utf-8'
        success: (msg) ->
          console.log msg
          watchWithHttp(url, $textarea, JSON.parse(msg), setting)


watchWithHttp = (url, $textarea, data, setting) ->
  switch data.method
    when 'inited'
      $textarea.data('background-color', $textarea.css('background-color'))
      $textarea.css('background-color', setting.color || '#4169e1')
      data.method = 'watch'
      $.ajax
        type: 'POST'
        data: JSON.stringify(data)
        contentType: 'application/json; charset=utf-8'
        url:  "#{url}/watch"
        success: (msg) ->
          watchWithHttp(url, $textarea, JSON.parse(msg), setting)
    when 'watched'
      $textarea.val(data.text) if data.text
      delete data.text
      data.method = 'watch'

      console.log(data) if setting.debug

      setTimeout ->
        $.ajax
          type: 'POST'
          url: "#{url}/watch"
          data: JSON.stringify(data)
          contentType: 'application/json; charset=utf-8'
          success: (msg) ->
            watchWithHttp(url, $textarea, JSON.parse(msg), setting)
      , setting.interval || 1000
    when 'finished'
      console.log(data) if setting.debug
      $textarea.val(data.text) if data.text

      chrome.extension.sendRequest { method: "activateTab" }, ->
        setTimeout ->
          $textarea.css('background-color', $textarea.data('background-color'))
        , 500


initConnection = (elem, setting) ->
  switch setting.protocol
      when 'ws'   then initWS   $(elem), getPosition(elem), setting
      when 'http' then initHttp $(elem), getPosition(elem), setting

$(document).on 'dblclick', 'textarea', ->
  that = this
  chrome.extension.sendRequest { method: "getSetting" }, (response) ->
    setting = response.data
    return unless setting.dblclick

    initConnection(that, setting)

$(document).on 'keydown', 'textarea', (e) ->
  that = this
  chrome.extension.sendRequest { method: "getSetting" }, (response) ->
    setting = response.data
    return unless setting.shortcut && eval(setting.shortcut)

    e.preventDefault()
    initConnection(that, setting)

