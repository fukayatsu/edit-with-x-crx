(function() {
  var getPosition, initConnection, initHttp, initWS, watchWithHttp;

  getPosition = function(elem) {
    var col, line, lines;
    lines = elem.value.substr(0, elem.selectionStart).split("\n");
    line = lines.length;
    col = lines[line - 1].length;
    return [line, col];
  };

  initWS = function($textarea, pos, setting) {
    var url, ws;
    url = "ws://0.0.0.0:" + (setting.port || 51234);
    ws = new WebSocket(url);
    ws.onerror = function() {
      return alert("server is not running on " + url + " ?");
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

  initHttp = function($textarea, pos, setting) {
    var url;
    url = "http://0.0.0.0:" + (setting.port || 51234);
    return $.ajax({
      type: "GET",
      url: url,
      error: function() {
        return alert("server is not running on " + url + " ?");
      },
      success: function(msg) {
        var data;
        if (msg !== 'ok') {
          return alert("error: server said " + msg);
        }
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
        return $.ajax({
          type: "POST",
          url: "" + url + "/init",
          data: data,
          success: function(msg) {
            return watchWithHttp(url, $textarea, JSON.parse(msg), setting);
          }
        });
      }
    });
  };

  watchWithHttp = function(url, $textarea, data, setting) {
    switch (data.method) {
      case 'inited':
        $textarea.data('background-color', $textarea.css('background-color'));
        $textarea.css('background-color', setting.color || '#4169e1');
        data.method = 'watch';
        return $.ajax({
          type: 'POST',
          url: "" + url + "/watch",
          data: data,
          success: function(msg) {
            return watchWithHttp(url, $textarea, JSON.parse(msg), setting);
          }
        });
      case 'watched':
        if (data.text) {
          $textarea.val(data.text);
        }
        delete data.text;
        data.method = 'watch';
        if (setting.debug) {
          console.log(data);
        }
        return setTimeout(function() {
          return $.ajax({
            type: 'POST',
            url: "" + url + "/watch",
            data: data,
            success: function(msg) {
              return watchWithHttp(url, $textarea, JSON.parse(msg), setting);
            }
          });
        }, setting.interval || 1000);
      case 'finished':
        if (setting.debug) {
          console.log(data);
        }
        return chrome.extension.sendRequest({
          method: "activateTab"
        }, function() {
          return setTimeout(function() {
            return $textarea.css('background-color', $textarea.data('background-color'));
          }, 500);
        });
    }
  };

  initConnection = function(elem, setting) {
    switch (setting.protocol) {
      case 'ws':
        return initWS($(elem), getPosition(elem), setting);
      case 'http':
        return initHttp($(elem), getPosition(elem), setting);
    }
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
      return initConnection(that, setting);
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
      return initConnection(that, setting);
    });
  });

}).call(this);
