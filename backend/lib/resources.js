import { nextId, store } from '../data/store.js';

export const resources = {
  users: {
    collection: store.users,
    prefix: 'usr',
    required: ['name', 'role', 'status'],
    searchable: ['name', 'role', 'status', 'phone'],
  },
  doctors: {
    collection: store.doctors,
    prefix: 'doc',
    required: ['name', 'specialty', 'status'],
    searchable: ['name', 'specialty', 'status', 'room'],
  },
  appointments: {
    collection: store.appointments,
    prefix: 'apt',
    required: ['patient', 'time', 'procedure', 'doctor'],
    searchable: ['patient', 'time', 'procedure', 'doctor', 'status'],
  },
  bookingSlots: {
    collection: store.bookingSlots,
    prefix: 'slot',
    required: ['time', 'room', 'doctor', 'type', 'status'],
    searchable: ['time', 'room', 'doctor', 'type', 'status'],
  },
  invoices: {
    collection: store.invoices,
    prefix: 'inv',
    required: ['patient', 'number', 'status', 'amount'],
    searchable: ['patient', 'number', 'status'],
  },
  followUps: {
    collection: store.followUps,
    prefix: 'fol',
    required: ['patient', 'reason', 'due', 'channel', 'priority'],
    searchable: ['patient', 'reason', 'due', 'channel', 'priority'],
  },
  procedures: {
    collection: store.procedures,
    prefix: 'pro',
    required: ['name', 'patient', 'stage', 'doctor'],
    searchable: ['name', 'patient', 'stage', 'doctor'],
  },
  projects: {
    collection: store.projects,
    prefix: 'prj',
    required: ['name', 'owner', 'deadline'],
    searchable: ['name', 'owner', 'deadline'],
  },
};

export function listResource(config, searchParams) {
  const role = searchParams.get('role');
  const query = searchParams.get('q')?.toLowerCase();

  return config.collection.filter((item) => {
    if (role && item.role !== role) {
      return false;
    }

    if (!query) {
      return true;
    }

    return config.searchable.some((key) =>
      String(item[key] ?? '').toLowerCase().includes(query),
    );
  });
}

export function createResource(config, body) {
  const errors = validateRequired(config.required, body);
  if (errors.length) {
    return { errors };
  }

  const item = {
    id: nextId(config.prefix),
    ...body,
  };

  config.collection.unshift(item);
  return { item };
}

export function updateResource(config, id, body) {
  const index = config.collection.findIndex((item) => item.id === id);
  if (index === -1) {
    return { notFound: true };
  }

  config.collection[index] = {
    ...config.collection[index],
    ...body,
    id,
  };

  return { item: config.collection[index] };
}

export function deleteResource(config, id) {
  const index = config.collection.findIndex((item) => item.id === id);
  if (index === -1) {
    return false;
  }

  config.collection.splice(index, 1);
  return true;
}

function validateRequired(fields, body) {
  return fields
    .filter((field) => body[field] === undefined || body[field] === '')
    .map((field) => `${field} is required`);
}
