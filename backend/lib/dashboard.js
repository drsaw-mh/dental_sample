import { store } from '../data/store.js';

export function buildDashboard() {
  const unpaidInvoices = store.invoices.filter((invoice) => !invoice.paid);
  const pendingFollowUps = store.followUps.filter((followUp) => !followUp.completed);
  const activeProcedures = store.procedures.filter(
    (procedure) => procedure.progress < 1,
  );

  return {
    metrics: {
      todayAppointments: store.appointments.length,
      pendingFollowUps: pendingFollowUps.length,
      cashDue: unpaidInvoices.reduce((sum, invoice) => sum + Number(invoice.amount), 0),
      activeProcedures: activeProcedures.length,
    },
    schedule: store.appointments,
    operationsPulse: {
      doctorUtilization: average(store.doctors.map((doctor) => doctor.utilization)),
      procedureRoomLoad: 0.64,
      cashierQueueCleared: {
        cleared: store.invoices.filter((invoice) => invoice.paid).length,
        total: store.invoices.length,
      },
      followUpCompletion: ratio(
        store.followUps.filter((followUp) => followUp.completed).length,
        store.followUps.length,
      ),
    },
  };
}

function average(values) {
  if (values.length === 0) {
    return 0;
  }

  return round(values.reduce((sum, value) => sum + Number(value), 0) / values.length);
}

function ratio(value, total) {
  if (total === 0) {
    return 0;
  }

  return round(value / total);
}

function round(value) {
  return Math.round(value * 100) / 100;
}
