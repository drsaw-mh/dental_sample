import { after, before, describe, it } from 'node:test';
import assert from 'node:assert/strict';
import { createApp } from '../server.js';

let server;
let baseUrl;

describe('DentalOps API', () => {
  before(async () => {
    server = createApp();
    await listen(server);
    const { port } = server.address();
    baseUrl = `http://127.0.0.1:${port}`;
  });

  after(async () => {
    await new Promise((resolve, reject) => {
      server.close((error) => (error ? reject(error) : resolve()));
    });
  });

  it('returns health status', async () => {
    const response = await fetch(`${baseUrl}/health`);
    const body = await response.json();

    assert.equal(response.status, 200);
    assert.equal(body.status, 'ok');
  });

  it('returns dashboard metrics', async () => {
    const response = await fetch(`${baseUrl}/api/dashboard`);
    const body = await response.json();

    assert.equal(response.status, 200);
    assert.equal(typeof body.data.metrics.todayAppointments, 'number');
    assert.ok(Array.isArray(body.data.schedule));
  });

  it('returns booking metrics, slots, and appointment queue', async () => {
    const response = await fetch(`${baseUrl}/api/booking`);
    const body = await response.json();

    assert.equal(response.status, 200);
    assert.equal(typeof body.data.metrics.openSlots, 'number');
    assert.ok(Array.isArray(body.data.slots));
    assert.ok(Array.isArray(body.data.queue));
  });

  it('creates an appointment through booking', async () => {
    const response = await fetch(`${baseUrl}/api/booking`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        patient: 'Lina Ong',
        time: '15:30',
        procedure: 'Consultation',
        doctor: 'Dr. Marcus Lee',
        slotId: 'slot_002',
      }),
    });
    const body = await response.json();

    assert.equal(response.status, 201);
    assert.equal(body.data.patient, 'Lina Ong');
    assert.equal(body.data.status, 'Scheduled');
  });

  it('creates a project', async () => {
    const response = await fetch(`${baseUrl}/api/projects`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        name: 'Inventory barcode rollout',
        owner: 'Operations',
        deadline: 'Jul 15',
        progress: 0,
        color: '#0B7285',
      }),
    });
    const body = await response.json();

    assert.equal(response.status, 201);
    assert.equal(body.data.name, 'Inventory barcode rollout');
    assert.equal(body.data.owner, 'Operations');
  });

  it('creates and updates a follow-up', async () => {
    const createResponse = await fetch(`${baseUrl}/api/followUps`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        patient: 'Nora Aziz',
        reason: 'Crown fitting confirmation',
        due: 'Monday',
        channel: 'Phone call',
        priority: 'Medium',
      }),
    });
    const createBody = await createResponse.json();

    assert.equal(createResponse.status, 201);
    assert.equal(createBody.data.patient, 'Nora Aziz');

    const updateResponse = await fetch(`${baseUrl}/api/followUps/${createBody.data.id}`, {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ completed: true }),
    });
    const updateBody = await updateResponse.json();

    assert.equal(updateResponse.status, 200);
    assert.equal(updateBody.data.completed, true);
  });

  it('validates required fields', async () => {
    const response = await fetch(`${baseUrl}/api/invoices`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ patient: 'Missing Invoice' }),
    });
    const body = await response.json();

    assert.equal(response.status, 422);
    assert.ok(body.error.details.includes('number is required'));
  });
});

function listen(server) {
  return new Promise((resolve, reject) => {
    server.once('error', reject);
    server.listen(0, '127.0.0.1', () => {
      server.off('error', reject);
      resolve();
    });
  });
}
