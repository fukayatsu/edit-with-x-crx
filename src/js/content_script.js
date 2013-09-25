var setWSEvent = function ($area, setting) {
  var ws = new WebSocket("ws://localhost:" + setting['port']);

  ws.onopen = function() {
    var data = {
      method: 'init',
      text: $area.is('textarea') ? $area.val() : $area.html().split('<br>').join(''),
      editor: setting['editor'],
      options: setting['options']
    };

    if (setting.debug) {
      console.log(data);
    }
    ws.send(JSON.stringify(data));
  };

  ws.onmessage = function(event) {
    var data = JSON.parse(event.data);
    if (setting.debug) {
      console.log(data);
    }

    switch(data.method) {
    case 'inited':
      ws.send(JSON.stringify({
        method: 'watch',
        tempfile: data.tempfile
      }));
      break;
    case 'watched':
      if (data.text !== undefined) {
        if ($area.is('textarea')) {
          $area.val(data.text);
        } else {
          $area.html('<div>' + data.text.split('\n').join('</div><div>') + '</div>');
        }
      }

      setTimeout(function() {
        if (ws.readyState != ws.OPEN) { return; }
        ws.send(JSON.stringify({
          method: 'watch',
          tempfile: data.tempfile
        }));
      }, 1000);
      break;
    }
  };
};


chrome.extension.sendRequest({
  method: "getSetting"
}, function(response) {
  var setting = response.data;

  if (setting.double_click) {
    $(document).on('dblclick', 'textarea,[contenteditable=true]', function() {
      setWSEvent($(this), setting);
    });
  }

  if (setting.shortcut) {
    $(document).on('keydown', 'textarea,[contenteditable=true]', function(e) {
      if (eval(setting.shortcut)) {
        e.preventDefault();
        setWSEvent($(this), setting);
      }
    });
  }
});