chrome.browserAction.onClicked.addListener (tab) ->
  chrome.tabs.create
     url: chrome.extension.getURL("/pages/options.html")

chrome.extension.onRequest.addListener (request, sender, sendResponse) ->
  setting = localStorage.getItem('setting')
  console.log request if setting && setting.debug
  switch request.method
    when "getSetting"
      sendResponse { data: JSON.parse(setting) }
    when "activateTab"
      chrome.tabs.update sender.tab.id, { active: true }, ->
        sendResponse {}
    else
      sendResponse {}
