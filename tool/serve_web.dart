import 'dart:io';

const _mimeTypes = {
  '.html': 'text/html; charset=utf-8',
  '.js': 'application/javascript; charset=utf-8',
  '.mjs': 'application/javascript; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.svg': 'image/svg+xml',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.ico': 'image/x-icon',
  '.wav': 'audio/wav',
  '.wasm': 'application/wasm',
  '.otf': 'font/otf',
  '.ttf': 'font/ttf',
  '.woff': 'font/woff',
  '.woff2': 'font/woff2',
};

Future<void> main() async {
  final root = Directory('build/web');
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 8080);
  stdout.writeln('Serving build/web at http://127.0.0.1:8080');

  await for (final req in server) {
    var relPath = Uri.decodeComponent(req.uri.path);
    if (relPath == '/' || relPath.isEmpty) {
      relPath = '/index.html';
    }
    var file = File('${root.path}$relPath');
    if (!await file.exists()) {
      file = File('${root.path}/index.html');
    }
    final dot = file.path.lastIndexOf('.');
    final ext = dot >= 0 ? file.path.substring(dot).toLowerCase() : '';
    req.response.headers.set(
      HttpHeaders.contentTypeHeader,
      _mimeTypes[ext] ?? 'application/octet-stream',
    );
    await req.response.addStream(file.openRead());
    await req.response.close();
  }
}
