$ ->
  setting = localStorage.getItem 'setting-yaml'
  if setting
    $('#inputSetting').val setting

$('#save').on 'click', ->
  inputSetting = $('#inputSetting').val()
  try
    setting = jsyaml.load(inputSetting)
    localStorage.setItem 'setting',      JSON.stringify(setting)
    localStorage.setItem 'setting-yaml', inputSetting
    alert 'saved.'
  catch error
    alert 'invalid yaml?'