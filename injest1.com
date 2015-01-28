// This helps avoid conflicts in case we inject
// this script on the same page multiple times
// without reloading.
var injected = injected || (function() {

    // An object that will contain the "methods"
    // we can use from our event script.
    var methods = {};

    // This method will eventually return
    // background colors from the current page.
    // Return all of the background-color values
    methods.getBgColors = function() {
        // Stores the colors and the number of occurrences
        var colors = {};
        // Get all the nodes on a page
        var nodes = document.querySelectorAll('*');
        // Instantiate variables we'll use later
        var node, nodeArea, bgColor, i;

        // Loop through all the nodes
        for (i = 0; i < nodes.length; i++) {
            // The current node
            node = nodes[i];
            // The area in pixels occupied by the element
            nodeArea = node.clientWidth * node.clientHeight;
            // The computed background-color value
            bgColor = window.getComputedStyle(node)['background-color'];
            // Strip spaces from the color for succinctness
            bgColor = bgColor.replace(/ /g, '');
            // If the color is not white or fully transparent...
            if (
                bgColor != 'rgb(255,255,255)' &&
                !(bgColor.indexOf('rgba') === 0 && bgColor.substr(-3) === ',0)')
            ) {
                // ...set or override it in the colors object,
                // adding the current element area to the
                // existing value.
                colors[bgColor] = (colors[bgColor] >> 0) + nodeArea;
            }
        }

        // Sort and return the colors by
        // total area descending
        return Object.getOwnPropertyNames(colors).sort(function(a, b) {
            return colors[b] - colors[a];
        });
    }

    // This tells the script to listen for
    // messages from our extension.
    chrome.runtime.onMessage.addListener(function(request, sender, sendResponse) {
        var data = {};
        // If the method the extension has requested
        // exists, call it and assign its response
        // to data.
        if (methods.hasOwnProperty(request.method))
            data = methods[request.method]();
        // Send the response back to our extension.
        sendResponse({
            data: data
        });
        return true;
    });

    return true;
})();
