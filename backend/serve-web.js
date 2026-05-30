import { createReadStream, existsSync } from 'node:fs';
import { stat } from 'node:fs/promises';
import { createServer } from 'node:http';
import { extname, join, normalize, resolve, sep } from 'node:path';

const port = Number(process.env.WEB_PORT ?? 8080);
const webRoot = resolve(process.cwd(), '..', 'build', 'web');
const mimeTypes = {
  '.css': 'text/css; charset=utf-8',
  '.html': 'text/html; charset=utf-8',
  '.ico': 'image/x-icon',
  '.js': 'application/javascript; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.png': 'image/png',
  '.svg': 'image/svg+xml',
  '.wasm': 'application/wasm',
};

function sendFile(res, filePath) {
  const contentType = mimeTypes[extname(filePath)] ?? 'application/octet-stream';
  res.writeHead(200, { 'Content-Type': contentType });
  createReadStream(filePath).pipe(res);
}

function resolveAsset(pathname) {
  const decodedPath = decodeURIComponent(pathname);
  const cleanPath = normalize(decodedPath).replace(/^(\.\.[/\\])+/, '');
  const requestedPath = resolve(join(webRoot, cleanPath));

  if (requestedPath !== webRoot && !requestedPath.startsWith(`${webRoot}${sep}`)) {
    return null;
  }

  return requestedPath;
}

const server = createServer(async (req, res) => {
  if (req.method !== 'GET' && req.method !== 'HEAD') {
    res.writeHead(405, { 'Content-Type': 'text/plain; charset=utf-8' });
    res.end('Method not allowed');
    return;
  }

  const url = new URL(req.url ?? '/', 'http://localhost');
  const requestedPath = resolveAsset(url.pathname === '/' ? '/index.html' : url.pathname);

  if (!existsSync(webRoot)) {
    res.writeHead(500, { 'Content-Type': 'text/plain; charset=utf-8' });
    res.end('Run `flutter build web` before starting the web server.');
    return;
  }

  if (requestedPath) {
    try {
      const fileStat = await stat(requestedPath);
      if (fileStat.isFile()) {
        sendFile(res, requestedPath);
        return;
      }
    } catch {
      // Fall through to the Flutter SPA fallback.
    }
  }

  sendFile(res, join(webRoot, 'index.html'));
});

server.listen(port, '127.0.0.1', () => {
  console.log(`DentalOps web running on http://127.0.0.1:${port}`);
});
