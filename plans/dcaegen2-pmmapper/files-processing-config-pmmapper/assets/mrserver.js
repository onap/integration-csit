var httpServer = function () {
  var http = require('http'),
      url = require('url'),
      fs = require('fs'),

      start = function (port) {
        var server = http.createServer(function (req, res) {
          processHttpRequest(res);
        });
        server.listen(port, function () {
          console.log('Listening on ' + port + '...');
        });
      },

      processHttpRequest = function (res) {
        res.writeHead(200, {'Content-Type': 'text/plain'});
        console.log('received message');
        setTimeout(() => {
          res.end('Published Successfully.\n');
        }, 100);
      };

  return {
    start: start
  }
}();

httpServer.start(3904);
