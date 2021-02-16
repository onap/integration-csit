var httpServer = function() {
var http = require('http'),
url = require('url'),
fs = require('fs'),

start = function(port) {
    var server = http.createServer(function(req, res) {
    processHttpRequest(res);	
    });
    server.listen(port, function() {
        console.log('Listening on ' + port + '...');
    });
},

processHttpRequest = function(res) {
    res.writeHead(200, {'Content-Type': 'text/plain'});
    setTimeout(() => {
            res.end(`Published Successfully.`);
        }, 2000)
};

return {
    start: start		
}
}();

httpServer.start(3904);
