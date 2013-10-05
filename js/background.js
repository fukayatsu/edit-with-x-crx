(function() {
  chrome.browserAction.onClicked.addListener(function(tab) {
    return chrome.tabs.create({
      url: chrome.extension.getURL("/pages/options.html")
    });
  });

  chrome.extension.onRequest.addListener(function(request, sender, sendResponse) {
    var setting;
    setting = localStorage.getItem('setting');
    if (setting && setting.debug) {
      console.log(request);
    }
    switch (request.method) {
      case "getSetting":
        return sendResponse({
          data: JSON.parse(setting)
        });
      case "activateTab":
        return chrome.tabs.update(sender.tab.id, {
          active: true
        }, function() {
          return sendResponse({});
        });
      default:
        return sendResponse({});
    }
  });

}).call(this);
