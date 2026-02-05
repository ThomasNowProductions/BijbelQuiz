"use client";

import { useEffect, useState } from "react";

type EventItem = {
  _id: string;
  title: string;
  description: string;
  type: "incident" | "maintenance";
  severity: "minor" | "major" | "critical";
  status: "ongoing" | "resolved" | "scheduled";
  startsAt: number;
  endsAt?: number;
};

const emptyForm: {
  title: string;
  description: string;
  type: EventItem["type"];
  severity: EventItem["severity"];
  status: EventItem["status"];
  startsAt: string;
  endsAt: string;
} = {
  title: "",
  description: "",
  type: "incident",
  severity: "minor",
  status: "ongoing",
  startsAt: "",
  endsAt: ""
};

function toLocalInput(value?: number) {
  if (!value) return "";
  const date = new Date(value);
  const local = new Date(date.getTime() - date.getTimezoneOffset() * 60000);
  return local.toISOString().slice(0, 16);
}

export default function AdminClient() {
  const [events, setEvents] = useState<EventItem[]>([]);
  const [form, setForm] = useState(emptyForm);
  const [editingId, setEditingId] = useState<string | null>(null);
  const [editForm, setEditForm] = useState(emptyForm);
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState<string | null>(null);

  const loadEvents = async () => {
    const res = await fetch("/api/admin/events", { cache: "no-store" });
    if (res.ok) {
      const data = await res.json();
      setEvents(data.events);
    }
  };

  useEffect(() => {
    loadEvents();
  }, []);

  const submit = async (event: React.FormEvent) => {
    event.preventDefault();
    setLoading(true);
    setMessage(null);

    const payload = {
      ...form,
      startsAt: form.startsAt ? new Date(form.startsAt).getTime() : Date.now(),
      endsAt: form.endsAt ? new Date(form.endsAt).getTime() : undefined
    };

    const res = await fetch("/api/admin/events", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload)
    });

    if (!res.ok) {
      const error = await res.json();
      setMessage(error.error ?? "Failed to create event");
    } else {
      setForm(emptyForm);
      setMessage("Event created.");
      await loadEvents();
    }
    setLoading(false);
  };

  const resolveEvent = async (id: string) => {
    setLoading(true);
    setMessage(null);
    const res = await fetch("/api/admin/events", {
      method: "PATCH",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ id })
    });

    if (!res.ok) {
      const error = await res.json();
      setMessage(error.error ?? "Failed to resolve event");
    } else {
      setMessage("Event resolved.");
      await loadEvents();
    }
    setLoading(false);
  };

  const startEdit = (event: EventItem) => {
    setEditingId(event._id);
    setEditForm({
      title: event.title,
      description: event.description,
      type: event.type,
      severity: event.severity,
      status: event.status,
      startsAt: toLocalInput(event.startsAt),
      endsAt: toLocalInput(event.endsAt)
    });
  };

  const cancelEdit = () => {
    setEditingId(null);
    setEditForm(emptyForm);
  };

  const updateEvent = async (event: React.FormEvent) => {
    event.preventDefault();
    if (!editingId) return;
    setLoading(true);
    setMessage(null);

    const payload = {
      action: "update",
      id: editingId,
      ...editForm,
      startsAt: editForm.startsAt
        ? new Date(editForm.startsAt).getTime()
        : undefined,
      endsAt: editForm.endsAt ? new Date(editForm.endsAt).getTime() : undefined
    };

    const res = await fetch("/api/admin/events", {
      method: "PATCH",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload)
    });

    if (!res.ok) {
      const error = await res.json();
      setMessage(error.error ?? "Failed to update event");
    } else {
      setMessage("Event updated.");
      setEditingId(null);
      setEditForm(emptyForm);
      await loadEvents();
    }
    setLoading(false);
  };

  return (
    <div className="container" style={{ paddingTop: 32 }}>
      <h1>Admin Console</h1>
      <p className="subtitle">
        Add incidents and maintenance updates. This area is secured with Basic
        Auth and a Convex admin secret.
      </p>

      <form className="card" onSubmit={submit} style={{ marginTop: 24 }}>
        <h3>Create Event</h3>
        <div className="grid" style={{ marginTop: 16 }}>
          <label>
            Title
            <input
              required
              value={form.title}
              onChange={(e) => setForm({ ...form, title: e.target.value })}
              className="input"
            />
          </label>
          <label>
            Type
            <select
              value={form.type}
              onChange={(e) =>
                setForm({
                  ...form,
                  type: e.target.value as EventItem["type"]
                })
              }
              className="input"
            >
              <option value="incident">Incident</option>
              <option value="maintenance">Maintenance</option>
            </select>
          </label>
          <label>
            Severity
            <select
              value={form.severity}
              onChange={(e) =>
                setForm({
                  ...form,
                  severity: e.target.value as EventItem["severity"]
                })
              }
              className="input"
            >
              <option value="minor">Minor</option>
              <option value="major">Major</option>
              <option value="critical">Critical</option>
            </select>
          </label>
          <label>
            Status
            <select
              value={form.status}
              onChange={(e) =>
                setForm({
                  ...form,
                  status: e.target.value as EventItem["status"]
                })
              }
              className="input"
            >
              <option value="ongoing">Ongoing</option>
              <option value="resolved">Resolved</option>
              <option value="scheduled">Scheduled</option>
            </select>
          </label>
          <label>
            Starts At
            <input
              type="datetime-local"
              value={form.startsAt}
              onChange={(e) => setForm({ ...form, startsAt: e.target.value })}
              className="input"
            />
          </label>
          <label>
            Ends At (optional)
            <input
              type="datetime-local"
              value={form.endsAt}
              onChange={(e) => setForm({ ...form, endsAt: e.target.value })}
              className="input"
            />
          </label>
        </div>
        <label style={{ marginTop: 16, display: "block" }}>
          Description
          <textarea
            required
            value={form.description}
            onChange={(e) =>
              setForm({ ...form, description: e.target.value })
            }
            className="input"
            rows={4}
          />
        </label>
        <button
          type="submit"
          className="button"
          disabled={loading}
          style={{ marginTop: 16 }}
        >
          {loading ? "Working..." : "Publish Event"}
        </button>
        {message ? <p className="subtitle">{message}</p> : null}
      </form>

      <section style={{ marginTop: 32 }}>
        <div className="section-title">
          <h2>Existing Events</h2>
          <span className="subtitle">{events.length} total</span>
        </div>
        <div className="event-list">
          {events.map((event) => (
            <article key={event._id} className="event">
              <div className="event-header">
                <div>
                  <h3>{event.title}</h3>
                  <p className="subtitle">
                    {new Date(event.startsAt).toLocaleString()}
                  </p>
                </div>
                <div style={{ display: "flex", gap: 8, alignItems: "center" }}>
                  <span className={`badge ${event.type}`}>{event.type}</span>
                  <span className={`badge ${event.status}`}>
                    {event.status}
                  </span>
                  <button
                    className="button button-outline"
                    onClick={() => startEdit(event)}
                    disabled={loading}
                  >
                    Edit
                  </button>
                  {event.status !== "resolved" ? (
                    <button
                      className="button button-outline"
                      onClick={() => resolveEvent(event._id)}
                      disabled={loading}
                    >
                      Resolve
                    </button>
                  ) : null}
                </div>
              </div>
              <p className="subtitle" style={{ marginTop: 12 }}>
                {event.description}
              </p>
              {editingId === event._id ? (
                <form className="card" onSubmit={updateEvent} style={{ marginTop: 16 }}>
                  <h3>Edit Event</h3>
                  <div className="grid" style={{ marginTop: 16 }}>
                    <label>
                      Title
                      <input
                        required
                        value={editForm.title}
                        onChange={(e) =>
                          setEditForm({ ...editForm, title: e.target.value })
                        }
                        className="input"
                      />
                    </label>
                    <label>
                      Type
                      <select
                        value={editForm.type}
                        onChange={(e) =>
                          setEditForm({
                            ...editForm,
                            type: e.target.value as EventItem["type"]
                          })
                        }
                        className="input"
                      >
                        <option value="incident">Incident</option>
                        <option value="maintenance">Maintenance</option>
                      </select>
                    </label>
                    <label>
                      Severity
                      <select
                        value={editForm.severity}
                        onChange={(e) =>
                          setEditForm({
                            ...editForm,
                            severity: e.target.value as EventItem["severity"]
                          })
                        }
                        className="input"
                      >
                        <option value="minor">Minor</option>
                        <option value="major">Major</option>
                        <option value="critical">Critical</option>
                      </select>
                    </label>
                    <label>
                      Status
                      <select
                        value={editForm.status}
                        onChange={(e) =>
                          setEditForm({
                            ...editForm,
                            status: e.target.value as EventItem["status"]
                          })
                        }
                        className="input"
                      >
                        <option value="ongoing">Ongoing</option>
                        <option value="resolved">Resolved</option>
                        <option value="scheduled">Scheduled</option>
                      </select>
                    </label>
                    <label>
                      Starts At
                      <input
                        type="datetime-local"
                        value={editForm.startsAt}
                        onChange={(e) =>
                          setEditForm({
                            ...editForm,
                            startsAt: e.target.value
                          })
                        }
                        className="input"
                      />
                    </label>
                    <label>
                      Ends At (optional)
                      <input
                        type="datetime-local"
                        value={editForm.endsAt}
                        onChange={(e) =>
                          setEditForm({ ...editForm, endsAt: e.target.value })
                        }
                        className="input"
                      />
                    </label>
                  </div>
                  <label style={{ marginTop: 16, display: "block" }}>
                    Description
                    <textarea
                      required
                      value={editForm.description}
                      onChange={(e) =>
                        setEditForm({
                          ...editForm,
                          description: e.target.value
                        })
                      }
                      className="input"
                      rows={4}
                    />
                  </label>
                  <div style={{ display: "flex", gap: 12, marginTop: 16 }}>
                    <button type="submit" className="button" disabled={loading}>
                      {loading ? "Working..." : "Save Changes"}
                    </button>
                    <button
                      type="button"
                      className="button button-outline"
                      onClick={cancelEdit}
                      disabled={loading}
                    >
                      Cancel
                    </button>
                  </div>
                </form>
              ) : null}
            </article>
          ))}
        </div>
      </section>
    </div>
  );
}
