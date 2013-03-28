chrome.extension.sendRequest({
  method: "getSetting"
}, function(response) {
  var setting = response.data;

  $('textarea').dblclick(function() {
    $this = $(this);
    var ws = new WebSocket("ws://localhost:" + setting['port']);
    ws.onopen = function() {
      ws.send(JSON.stringify({
        method: 'init',
        text: $this.val(),
        editor: setting['editor'],
        options: setting['options']
      }));
    };
    ws.onmessage = function(event) {
      var data = JSON.parse(event.data);

      switch(data.method) {
      case 'inited':
        ws.send(JSON.stringify({
          method: 'watch',
          tempfile: data.tempfile
        }));
        break;
      case 'watched':
        $this.val(data.text);

        setTimeout(function() {
          ws.send(JSON.stringify({
            method: 'watch',
            tempfile: data.tempfile
          }));
        }, 1000);
        break;
      }
    };
  });
});