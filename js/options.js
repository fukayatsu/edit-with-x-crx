(function() {
  $(function() {
    var setting;
    setting = localStorage.getItem('setting-yaml');
    if (setting) {
      return $('#inputSetting').val(setting);
    }
  });

  $('#save').on('click', function() {
    var error, inputSetting, setting;
    inputSetting = $('#inputSetting').val();
    try {
      setting = jsyaml.load(inputSetting);
      localStorage.setItem('setting', JSON.stringify(setting));
      localStorage.setItem('setting-yaml', inputSetting);
      return alert('saved.');
    } catch (_error) {
      error = _error;
      return alert('invalid yaml?');
    }
  });

}).call(this);
