(function() {
  var getPosition, initWS;

  getPosition = function(elem) {
    var col, line, lines;
    lines = elem.value.substr(0, elem.selectionStart).split("\n");
    line = lines.length;
    col = lines[line - 1].length;
    return [line, col];
  };

  initWS = function($textarea, pos, setting) {
    var address, ws;
    address = "ws://0.0.0.0:" + (setting.port || 51234);
    ws = new WebSocket(address);
    ws.onerror = function() {
      return alert("server is not running on " + address + " ?");
    };
    ws.onopen = function() {
      var data;
      data = {
        method: 'init',
        text: $textarea.val(),
        line: pos[0],
        col: pos[1],
        editor: setting.editor,
        command: setting.command,
        ext: setting.ext
      };
      if (setting.debug) {
        console.log(data);
      }
      return ws.send(JSON.stringify(data));
    };
    return ws.onmessage = function(event) {
      var data;
      data = JSON.parse(event.data);
      if (setting.debug) {
        console.log(data);
      }
      switch (data.method) {
        case 'inited':
          $textarea.data('background-color', $textarea.css('background-color'));
          $textarea.css('background-color', setting.color || '#4169e1');
          return ws.send(JSON.stringify({
            method: 'watch',
            pid: data.pid,
            tempfile: data.tempfile
          }));
        case 'watched':
          if (data.text) {
            $textarea.val(data.text);
          }
          return setTimeout(function() {
            if (ws.readyState === ws.OPEN) {
              return ws.send(JSON.stringify({
                method: 'watch',
                pid: data.pid,
                tempfile: data.tempfile
              }));
            } else {
              return chrome.extension.sendRequest({
                method: "activateTab"
              }, function() {
                return setTimeout(function() {
                  return $textarea.css('background-color', $textarea.data('background-color'));
                }, 500);
              });
            }
          }, setting.interval || 1000);
      }
    };
  };

  $(document).on('dblclick', 'textarea', function() {
    var that;
    that = this;
    return chrome.extension.sendRequest({
      method: "getSetting"
    }, function(response) {
      var setting;
      setting = response.data;
      if (!setting.dblclick) {
        return;
      }
      if (setting.double_click) {
        return initWS($(that), getPosition(that), setting);
      }
    });
  });

  $(document).on('keydown', 'textarea', function(e) {
    var that;
    that = this;
    return chrome.extension.sendRequest({
      method: "getSetting"
    }, function(response) {
      var setting;
      setting = response.data;
      if (!(setting.shortcut && eval(setting.shortcut))) {
        return;
      }
      e.preventDefault();
      if (setting.shortcut) {
        return initWS($(that), getPosition(that), setting);
      }
    });
  });

}).call(this);
