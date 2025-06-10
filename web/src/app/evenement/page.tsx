"use client";

import { useEffect, useState } from "react";
import { CalendarIcon, MapPinIcon } from "lucide-react";
import { api } from "@/lib/api/axios";

interface Event {
  id: number;
  titre: string;
  description: string;
  lieu: string;
  dateDebut: string; // ISO string
  dateFin?: string; // ISO string (optional)
  image?: string; // URL (optional)
}

export default function Page() {
  const [events, setEvents] = useState<Event[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    async function fetchEvents() {
      try {
        // Remplace la route ci‑dessous par celle de ton backend
        const res = await api.get("/events/calendrier/");
        if (res.status < 200 || res.status >= 300)
          throw new Error("Impossible de récupérer les événements");
        const data: Event[] = await res.data;

        // Garder uniquement ceux à venir et trier par date
        const futurs = data
          .filter((e) => new Date(e.dateDebut).getTime() > Date.now())
          .sort(
            (a, b) =>
              new Date(a.dateDebut).getTime() - new Date(b.dateDebut).getTime()
          );

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
        <article key={ev.id} className="card bg-base-100 shadow-xl">
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
            <p className="text-sm opacity-80 line-clamp-3">{ev.description}</p>
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
            <div className="flex items-center gap-2 text-sm">
              <MapPinIcon size={18} />
              {ev.lieu}
            </div>
          </div>
        </article>
      ))}
    </main>
  );
}
