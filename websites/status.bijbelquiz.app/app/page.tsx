import { getConvexClient, api } from "../lib/convex";

function formatDate(value: number) {
  return new Intl.DateTimeFormat("en-GB", {
    dateStyle: "medium",
    timeStyle: "short"
  }).format(new Date(value));
}

function statusCopy(status: "operational" | "degraded" | "major") {
  if (status === "major") {
    return {
      title: "Major Outage",
      subtitle: "We are actively fixing a critical service disruption.",
      color: "var(--error)"
    };
  }
  if (status === "degraded") {
    return {
      title: "Degraded Performance",
      subtitle: "Some services are slower than usual. Updates below.",
      color: "var(--warning)"
    };
  }
  return {
    title: "All Systems Operational",
    subtitle: "",
    color: "var(--success)"
  };
}

export default async function StatusPage() {
  const client = getConvexClient();
  const status = await client.query(api.events.getStatus, { windowDays: 90 });
  const copy = statusCopy(status.currentStatus);

  return (
    <main>
      <div className="container">
        <header className="hero-layout">
          <div className="hero-content">
            <div className="hero-text">
              <span className="material-icons icon-large" aria-hidden>
                church
              </span>
              <h1>BijbelQuiz Status</h1>
              <p className="hero-description">
                Live service health, incident updates, and planned maintenance
                for the BijbelQuiz platform.
              </p>
            </div>
            <div className="status-pill">
              <span
                className="status-dot"
                style={{ background: copy.color }}
              />
              {copy.title}
            </div>
            {copy.subtitle ? (
              <p className="subtitle">{copy.subtitle}</p>
            ) : null}
          </div>
        </header>

        <div className="section-title">
          <div>
            <h2>Event Timeline</h2>
            <p className="subtitle">Most recent updates from the team.</p>
          </div>
        </div>

        <section className="event-list">
          {status.events.length === 0 ? (
            <div className="event">
              <div className="event-header">
                <h3>No incidents reported</h3>
                <span className="badge resolved">Clear</span>
              </div>
              <p className="subtitle">
                There have been no incidents or maintenance events recorded yet.
              </p>
            </div>
          ) : (
            status.events.map((event: any) => (
              <article className="event" key={event._id}>
                <div className="event-header">
                  <div>
                    <h3>{event.title}</h3>
                    <p className="subtitle">
                      {formatDate(event.startsAt)}
                      {event.endsAt
                        ? ` · Resolved ${formatDate(event.endsAt)}`
                        : " · Ongoing"}
                    </p>
                  </div>
                  <div style={{ display: "flex", gap: 8 }}>
                    <span className={`badge ${event.type}`}>{event.type}</span>
                    <span className={`badge ${event.status}`}>
                      {event.status}
                    </span>
                  </div>
                </div>
                <p className="subtitle" style={{ marginTop: 12 }}>
                  {event.description}
                </p>
              </article>
            ))
          )}
        </section>

      </div>
    </main>
  );
}
