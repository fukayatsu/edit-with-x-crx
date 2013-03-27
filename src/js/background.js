(function(){
  chrome.browserAction.onClicked.addListener(function(tab){
    chrome.tabs.create({
       "url": chrome.extension.getURL("options.html")
    });
  });

  chrome.extension.onRequest.addListener(function(request, sender, sendResponse) {
    if (request.method == "getSetting") {
      var setting = localStorage.getItem('setting');
      sendResponse({data: setting});
    } else {
      sendResponse({});
    }
  });
})();