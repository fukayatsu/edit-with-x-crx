chrome.extension.sendRequest({
  method: "getSetting"
}, function(response) {
  var setting = response.data;

  $('textarea').dblclick(function() {
    $this = $(this);
    $.ajax({
      url: 'http://localhost:9292/edit',
      data: $this.val(),
      type: 'POST',
      dataType: 'json',
      contentType: 'applicatioin/json',
      success: function(xhr) {
        if (xhr.status == 'quit') {
          $this.val(xhr.data);
        } else if (xhr.status == 'save') {
          $this.val(xhr.data);
          // continue poling
        }
      }
    });
  });
});