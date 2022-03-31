import 'dart:io';
import 'dart:convert' show utf8;

var outputFile = File('logs.log');
void log(dynamic map) {
  var now = DateTime.now().toUtc().toIso8601String();
  outputFile.writeAsStringSync("$now --->\n $map\n\n", mode: FileMode.append);
}

Future<void> handleRequests(HttpServer server) async {
  await for (HttpRequest request in server) {
    try {
      Map<String, dynamic> map = <String, dynamic>{};
      map["contentLength"] = request.contentLength;
      map["method"] = request.method;
      map["headers"] = request.headers;
      map["body"] = await utf8.decodeStream(request);
      map['url'] = request.requestedUri;
      log(map);
      request.response.write(
          'You have pinged the test dart server.Your request parameters will be logged');
      await request.response.close();
    } on Error catch (e) {
      log(e);
    }
  }
}

Future<void> main() async {
  final server = await createServer();
  print('Server started: ${server.address} port ${server.port}');
  await handleRequests(server);
}

Future<HttpServer> createServer() async {
  final address = InternetAddress.loopbackIPv4;
  const port = 10000;
  return await HttpServer.bind(address, port);
}
