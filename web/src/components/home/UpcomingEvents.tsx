"use client";

import { useEffect, useState } from "react";
import { fetchAllEvents } from "@/lib/api/evenement";
import { ApiEvent } from "@/types/evenement";
import Link from "next/link";

export default function UpcomingEvents() {
  const [events, setEvents] = useState<ApiEvent[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchAllEvents()
      .then((e) => setEvents(e.slice(0, 5))) // affiche les 5 prochains
      .catch(console.error)
      .finally(() => setLoading(false));
  }, []);

  if (loading) {
    return (
      <div className="flex justify-center p-4">
        <span className="loading loading-spinner" />
      </div>
    );
  }

  return (
    <div className="bg-base-100 p-6 rounded-2xl shadow-lg">
      <h3 className="text-xl font-bold mb-4">Évènements à venir</h3>
      {events.length ? (
        <ul className="space-y-4">
          {events.map((ev) => (
            <li key={ev.id} className="flex flex-col">
              <p className="font-semibold text-sm">{ev.titre}</p>
              <p className="text-xs text-base-content/70">
                {new Date(ev.date_debut).toLocaleDateString()} - {new Date(ev.date_fin).toLocaleDateString()}
              </p>
              <Link href={`/events/${ev.id}`} className="link link-primary text-xs mt-1 w-fit">Voir plus</Link>
            </li>
          ))}
        </ul>
      ) : (
        <p className="text-base-content/70">Aucun évènement prévu.</p>
      )}
    </div>
  );
}
