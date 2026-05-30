import { nextId, store } from '../data/store.js';

export function buildBooking() {
  const openSlots = store.bookingSlots.filter((slot) => slot.status === 'Open');

  return {
    metrics: {
      openSlots: openSlots.length,
      confirmed: store.appointments.length,
      walkIns: 6,
      chairLoad: 0.68,
    },
    slots: store.bookingSlots,
    queue: store.appointments,
  };
}

export function createBooking(body) {
  const required = ['patient', 'time', 'procedure', 'doctor'];
  const errors = required
    .filter((field) => body[field] === undefined || body[field] === '')
    .map((field) => `${field} is required`);

  if (errors.length) {
    return { errors };
  }

  const appointment = {
    id: nextId('apt'),
    patient: body.patient,
    time: body.time,
    procedure: body.procedure,
    doctor: body.doctor,
    chair: body.chair ?? 'Triage',
    status: body.status ?? 'Scheduled',
    color: body.color ?? '#0B7285',
    notes: body.notes ?? '',
  };

  store.appointments.unshift(appointment);

  if (body.slotId) {
    const slot = store.bookingSlots.find((item) => item.id === body.slotId);
    if (slot) {
      slot.status = 'Booked';
    }
  }

  return { appointment };
}
