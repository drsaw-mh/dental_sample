# DentalOps

Cross-platform Flutter dental clinic app with a local Node.js REST backend.

## Frontend

Run the Flutter app:

```sh
flutter run
```

Build the web app:

```sh
flutter build web
```

## Backend

Run the API:

```sh
cd backend
npm start
```

The backend runs on:

```text
http://127.0.0.1:4000
```

No install step is required because the backend uses built-in Node.js modules.

## API

Health:

```text
GET /health
```

Dashboard:

```text
GET /api/dashboard
```

Booking:

```text
GET  /api/booking
POST /api/booking
```

Clinic resources:

```text
GET    /api/users
POST   /api/users
PATCH  /api/users/:id
DELETE /api/users/:id

GET    /api/doctors
GET    /api/appointments
GET    /api/bookingSlots
GET    /api/invoices
GET    /api/followUps
GET    /api/procedures
GET    /api/projects
```

Every resource supports `GET`, `POST`, `PATCH`, and `DELETE`. List endpoints also support search:

```text
GET /api/users?q=doctor
GET /api/users?role=Doctor
```

Run backend tests:

```sh
cd backend
npm test
```
