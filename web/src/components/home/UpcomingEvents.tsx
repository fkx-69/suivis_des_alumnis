"use client";

import { useEffect, useState } from "react";
import { fetchAllEvents } from "@/lib/api/evenement";
import { ApiEvent } from "@/types/evenement";
import { Carousel } from "@/components/ui/carousel";
import EventCard from "@/components/EventCard";

export default function UpcomingEvents() {
  const [events, setEvents] = useState<ApiEvent[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchAllEvents()
      .then((e) => setEvents(e.slice(0, 5))) // Affiche les 5 prochains
      .catch(console.error)
      .finally(() => setLoading(false));
  }, []);

  if (loading) {
    return (
      <div className="flex justify-center p-8 h-48 items-center">
        <span className="loading loading-spinner loading-lg" />
      </div>
    );
  }

  return (
    <div className="w-full">
      <h2 className="text-3xl font-bold text-center mb-2">
        Évènements à venir
      </h2>
      {events.length > 0 ? (
        <Carousel>
          {events.map((event) => (
            <EventCard
              event={event}
              key={event.id}
              className="carousel-card snap-center w-full md:w-[450px] flex-shrink-0 transition-all duration-300"
            />
          ))}
        </Carousel>
      ) : (
        <div className="text-center text-base-content/70 p-8 bg-base-200 rounded-2xl">
          <p>Aucun évènement prévu pour le moment.</p>
        </div>
      )}
    </div>
  );
}
