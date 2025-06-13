import { CalendarIcon } from "lucide-react";

export interface EventCardProps {
  event: {
    titre: string;
    description: string;
    date_debut: string;
    date_fin?: string;
    image?: string;
  };
  expanded?: boolean;
  onToggle?(): void;
}

export default function EventCard({ event, expanded, onToggle }: EventCardProps) {
  return (
    <div
      className={`card card-lg w-96 bg-base-100 ${event.image ? "" : "card-xl"} shadow-sm`}
      onClick={onToggle}
    >
      {event.image && (
        <figure>
          <img src={event.image} alt={event.titre} className="h-48 w-full object-cover" />
        </figure>
      )}
      <div className="card-body">
        <h2 className="card-title">{event.titre || ""}</h2>
        <p className={`text-sm opacity-80 cursor-pointer ${expanded ? "" : "line-clamp-3"}`}>
          {event.description || ""}
        </p>
        {event.date_debut && (
          <div className="flex items-center gap-2 mt-2 text-sm">
            <CalendarIcon size={18} />
            {new Date(event.date_debut).toLocaleString(undefined, {
              weekday: "short",
              day: "numeric",
              month: "short",
              year: "numeric",
              hour: "2-digit",
              minute: "2-digit",
            })}
          </div>
        )}
      </div>
    </div>
  );
}
