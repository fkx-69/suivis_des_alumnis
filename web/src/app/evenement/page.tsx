"use client";

import { useEffect, useState } from "react";
import { api } from "@/lib/api/axios";
import { ApiEvent } from "@/types/evenement";
import AddEventForm from "@/components/AddEventForm";
import EventCard from "@/components/EventCard";
import EventModal from "@/components/EventModal";

export default function Page() {
  const [events, setEvents] = useState<ApiEvent[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [selectedEvent, setSelectedEvent] = useState<ApiEvent | null>(null);
  const [showForm, setShowForm] = useState(false);
  const [showMyEvents, setShowMyEvents] = useState(false);

  useEffect(() => {
    async function fetchEvents() {
      try {
        const res = await api.get<ApiEvent[]>("/events/evenements/");
        if (res.status < 200 || res.status >= 300) {
          throw new Error("Impossible de récupérer les événements");
        }

        const futurs = res.data
          .filter((e) => new Date(e.date_debut).getTime() > Date.now())
          .sort(
            (a, b) =>
              new Date(a.date_debut).getTime() -
              new Date(b.date_debut).getTime()
          );

        // On garde les mêmes clés que ton composant attend :
        setEvents(futurs);
      } catch (err: any) {
        setError(err.message ?? "Erreur inconnue");
      } finally {
        setLoading(false);
      }
    }

    fetchEvents();
  }, []);

  const handleCreated = (ev: ApiEvent) => {
    setEvents((prev) => [...prev, ev]);
    setShowForm(false);
  };

  if (loading) {
    return (
      <div className="flex justify-center mt-10">
        <span className="loading loading-spinner loading-lg"></span>
      </div>
    );
  }

  if (error) {
    return (
      <div className="alert alert-error max-w-lg mx-auto mt-10">
        <span>{error}</span>
      </div>
    );
  }

  return (
    <main className="p-4 lg:p-8">
      <div className="mb-4">
        <button
          className="btn btn-secondary"
          onClick={() => setShowMyEvents((s) => !s)}
        >
          Mes évènements
        </button>
      </div>
      {showForm && <AddEventForm onCreated={handleCreated} />}
      {(showMyEvents ? events.filter((e) => e.is_owner).length === 0 : events.length === 0) && (
        <div className="alert alert-info max-w-lg mx-auto mt-10">
          <span>Aucun événement futur pour le moment.</span>
        </div>
      )}
      <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
        {(showMyEvents ? events.filter((e) => e.is_owner) : events).map((ev) => (
          <EventCard key={ev.id} event={ev} onToggle={() => setSelectedEvent(ev)} />
        ))}
      </div>
      {selectedEvent && (
        <EventModal event={selectedEvent} onClose={() => setSelectedEvent(null)} />
      )}
      <button
        className="btn btn-secondary fixed bottom-4 left-4 w-12 h-12 rounded-full flex items-center justify-center"
        onClick={() => setShowForm((s) => !s)}
      >
        +
      </button>
    </main>
  );
}

