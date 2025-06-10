"use client";

import { useEffect, useState } from "react";
import { CalendarIcon } from "lucide-react";
import { api } from "@/lib/api/axios";
import { ApiEvent } from "@/types/evenement";

export default function Page() {
  const [events, setEvents] = useState<ApiEvent[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [expandedId, setExpandedId] = useState<number | null>(null);

  useEffect(() => {
    async function fetchEvents() {
      try {
        const res = await api.get<ApiEvent[]>("/events/calendrier/");
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

  if (events.length === 0) {
    return (
      <div className="alert alert-info max-w-lg mx-auto mt-10">
        <span>Aucun événement futur pour le moment.</span>
      </div>
    );
  }

  return (
    <main className="p-4 lg:p-8 grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
      {events.map((ev) => (
        <div
          key={ev.id}
          className={`card card-lg w-full bg-base-100 ${ev.image ? "" : "card-md"} shadow-sm`}
        >
          {ev.image && (
            <figure>
              <img
                src={ev.image}
                alt={ev.titre}
                className="h-48 w-full object-cover"
              />
            </figure>
          )}
          <div className="card-body">
            <h2 className="card-title">{ev.titre}</h2>
            <p
              className={`text-sm opacity-80 cursor-pointer ${
                expandedId === ev.id ? "" : "line-clamp-3"
              }`}
              onClick={() =>
                setExpandedId(expandedId === ev.id ? null : ev.id)
              }
            >
              {ev.description}
            </p>
            <div className="flex items-center gap-2 mt-2 text-sm">
              <CalendarIcon size={18} />
              {new Date(ev.dateDebut).toLocaleString(undefined, {
                weekday: "short",
                day: "numeric",
                month: "short",
                year: "numeric",
                hour: "2-digit",
                minute: "2-digit",
              })}
            </div>
          </div>
        </div>
      ))}
    </main>
  );
}
