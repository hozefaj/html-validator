// HTML inspector is a tool that based on W3C validator
// http://philipwalton.com/articles/introducing-html-inspector
// https://cdnjs.cloudflare.com/ajax/libs/html-inspector/0.8.1/html-inspector.js
chrome.browserAction.onClicked.addListener(function(tab) {

    chrome.tabs.executeScript(tab.id, {file: "inspector.js"}, function(){
        chrome.tabs.executeScript({
            code: 'HTMLInspector.inspect()'
        });
    });
});