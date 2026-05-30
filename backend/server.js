import { createServer } from 'node:http';
import { buildBooking, createBooking } from './lib/booking.js';
import { buildDashboard } from './lib/dashboard.js';
import { readJson, sendError, sendJson, sendNoContent } from './lib/http.js';
import {
  createResource,
  deleteResource,
  listResource,
  resources,
  updateResource,
} from './lib/resources.js';

const defaultPort = 4000;

export function createApp() {
  return createServer(async (req, res) => {
    try {
      if (req.method === 'OPTIONS') {
        sendNoContent(res);
        return;
      }

      const url = new URL(req.url ?? '/', 'http://localhost');
      const pathParts = url.pathname.split('/').filter(Boolean);

      if (url.pathname === '/health') {
        sendJson(res, 200, { status: 'ok', service: 'dental-app-backend' });
        return;
      }

      if (url.pathname === '/api/dashboard' && req.method === 'GET') {
        sendJson(res, 200, { data: buildDashboard() });
        return;
      }

      if (url.pathname === '/api/booking' && req.method === 'GET') {
        sendJson(res, 200, { data: buildBooking() });
        return;
      }

      if (url.pathname === '/api/booking' && req.method === 'POST') {
        const body = await readJson(req);
        const result = createBooking(body);

        if (result.errors) {
          sendError(res, 422, 'Validation failed.', result.errors);
          return;
        }

        sendJson(res, 201, { data: result.appointment });
        return;
      }

      if (pathParts[0] !== 'api') {
        sendError(res, 404, 'Route not found.');
        return;
      }

      const resourceName = pathParts[1];
      const resource = resources[resourceName];

      if (!resource) {
        sendError(res, 404, 'API resource not found.');
        return;
      }

      const id = pathParts[2];

      if (!id && req.method === 'GET') {
        sendJson(res, 200, { data: listResource(resource, url.searchParams) });
        return;
      }

      if (!id && req.method === 'POST') {
        const body = await readJson(req);
        const result = createResource(resource, body);

        if (result.errors) {
          sendError(res, 422, 'Validation failed.', result.errors);
          return;
        }

        sendJson(res, 201, { data: result.item });
        return;
      }

      if (id && req.method === 'PATCH') {
        const body = await readJson(req);
        const result = updateResource(resource, id, body);

        if (result.notFound) {
          sendError(res, 404, 'Item not found.');
          return;
        }

        sendJson(res, 200, { data: result.item });
        return;
      }

      if (id && req.method === 'DELETE') {
        if (!deleteResource(resource, id)) {
          sendError(res, 404, 'Item not found.');
          return;
        }

        sendNoContent(res);
        return;
      }

      sendError(res, 405, 'Method not allowed.');
    } catch (error) {
      sendError(
        res,
        error.statusCode ?? 500,
        error.statusCode ? error.message : 'Unexpected server error.',
      );
    }
  });
}

if (import.meta.url === `file://${process.argv[1]}`) {
  const port = Number(process.env.PORT ?? defaultPort);
  const server = createApp();

  server.listen(port, () => {
    console.log(`DentalOps API running on http://127.0.0.1:${port}`);
  });
}
