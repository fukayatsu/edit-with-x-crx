chrome.extension.sendRequest({
  method: "getSetting"
}, function(response) {
  var setting = response.data;

  $('textarea').dblclick(function() {
    $this = $(this);
    var ws = new WebSocket("ws://localhost:51234");
    ws.onopen = function() {
      ws.send($this.val());
    };
    ws.onmessage = function(event) {
      var data = JSON.parse(event.data);
      $this.val(data.text);
    };
  });
});