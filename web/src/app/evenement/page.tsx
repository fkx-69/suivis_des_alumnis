"use client";

import { useEffect, useState } from "react";

import { ApiEvent } from "@/types/evenement";
import AddEventModal from "@/components/AddEventModal";
import EventCard from "@/components/EventCard";
import EventModal from "@/components/EventModal";
import ConfirmModal from "@/components/ConfirmModal";
import {
  fetchEvents,
  fetchPendingEvents,
  deleteEvent,
} from "@/lib/api/evenement";
import { Plus } from "lucide-react";

export default function Page() {
  const [events, setEvents] = useState<ApiEvent[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [selectedEvent, setSelectedEvent] = useState<ApiEvent | null>(null);
  const [showForm, setShowForm] = useState(false);
  const [showMyEvents, setShowMyEvents] = useState(false);
  const [showPendingEvents, setShowPendingEvents] = useState(false);
  const [editingEvent, setEditingEvent] = useState<ApiEvent | null>(null);
  const [eventToDelete, setEventToDelete] = useState<ApiEvent | null>(null);

  useEffect(() => {
    setLoading(true);
    const fetcher = showPendingEvents ? fetchPendingEvents : fetchEvents;
    fetcher()
      .then(setEvents)
      .catch((err: unknown) => {
        if (err instanceof Error) {
          setError(err.message);
        } else {
          setError("Erreur inconnue");
        }
      })
      .finally(() => setLoading(false));
  }, [showPendingEvents]);

  const handleCreated = (ev: ApiEvent) => {
    setEvents((prev) => [...prev, ev]);
    setShowForm(false);
  };

  const handleUpdated = (ev: ApiEvent) => {
    setEvents((prev) => prev.map((e) => (e.id === ev.id ? ev : e)));
    setEditingEvent(null);
  };

  const requestDelete = (ev: ApiEvent) => {
    setEventToDelete(ev);
  };

  const confirmDelete = async () => {
    if (!eventToDelete) return;
    try {
      await deleteEvent(eventToDelete.id);
      setEvents((prev) => prev.filter((e) => e.id !== eventToDelete.id));
    } catch (err) {
      console.error(err);
    } finally {
      setEventToDelete(null);
    }
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

  const filteredEvents = showMyEvents
    ? events.filter((e) => e.is_owner)
    : showPendingEvents
      ? events.filter((e) => !e.valide)
      : events.filter((e) => e.valide);

  return (
    <main className="mx-auto max-w-7xl px-4 py-4 lg:py-8">
      <div className="mb-4 flex gap-2">
        <button
          className={`btn btn-primary ${!showMyEvents && !showPendingEvents ? "btn-active" : "btn-soft"}`}
          onClick={() => {
            setShowMyEvents(false);
            setShowPendingEvents(false);
          }}
        >
          Tous les évènements
        </button>
        <button
          className={`btn btn-primary ${showMyEvents ? "btn-active" : "btn-soft"}`}
          onClick={() => {
            setShowMyEvents(true);
            setShowPendingEvents(false);
          }}
        >
          Mes évènements
        </button>
        <button
          className={`btn btn-primary ${showPendingEvents ? "btn-active" : "btn-soft"}`}
          onClick={() => {
            setShowMyEvents(false);
            setShowPendingEvents(true);
          }}
        >
          En attente
        </button>
      </div>
      {showForm && (
        <AddEventModal
          onCreated={handleCreated}
          onClose={() => setShowForm(false)}
        />
      )}
      {editingEvent && (
        <AddEventModal
          event={editingEvent}
          onUpdated={handleUpdated}
          onClose={() => setEditingEvent(null)}
        />
      )}

      {filteredEvents.length === 0 ? (
        <div className="alert alert-info max-w-lg mx-auto mt-10">
          <span>Aucun futur événement pour le moment.</span>
        </div>
      ) : (
        <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
          {filteredEvents.map((ev) => (
            <EventCard
              key={ev.id}
              event={ev}
              onToggle={() => setSelectedEvent(ev)}
              showActions={showPendingEvents}
              onEdit={() => setEditingEvent(ev)}
              onDelete={() => requestDelete(ev)}
            />
          ))}
        </div>
      )}

      {selectedEvent && (
        <EventModal
          event={selectedEvent}
          onClose={() => setSelectedEvent(null)}
        />
      )}
      {eventToDelete && (
        <ConfirmModal
          title="Supprimer l'évènement"
          message={`Supprimer "${eventToDelete.titre}" ?`}
          confirmText="Supprimer"
          cancelText="Annuler"
          onConfirm={confirmDelete}
          onCancel={() => setEventToDelete(null)}
        />
      )}

      <button
        onClick={() => setShowForm((s) => !s)}
        className="btn btn-primary btn-circle fixed bottom-10 right-10 shadow-lg z-50"
        aria-label="Ajouter une publication"
      >
        <Plus size={28} />
      </button>
    </main>
  );
}
