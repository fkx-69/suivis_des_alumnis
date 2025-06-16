import { CalendarIcon, Edit2 as Pencil, Trash } from "lucide-react";

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
  showActions?: boolean;
  onEdit?(): void;
  onDelete?(): void;
}

export default function EventCard({
  event,
  expanded,
  onToggle,
  showActions,
  onEdit,
  onDelete,
}: EventCardProps) {
  return (
    <div
      className={`relative card card-lg w-96 bg-base-100 ${event.image ? "" : "card-xl"} shadow-sm`}
      onClick={onToggle}
    >
      {showActions && (
        <>
          <button
            className="btn btn-xs btn-circle absolute top-2 left-2 z-10"
            onClick={(e) => {
              e.stopPropagation();
              onEdit?.();
            }}
          >
            <Pencil size={12} />
          </button>
          <button
            className="btn btn-xs btn-circle btn-error absolute top-2 right-2 z-10"
            onClick={(e) => {
              e.stopPropagation();
              onDelete?.();
            }}
          >
            <Trash size={12} />
          </button>
        </>
      )}
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
