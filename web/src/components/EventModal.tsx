import { CalendarIcon, XIcon } from "lucide-react";
import { motion } from "framer-motion";
import { useEffect } from "react";
import { ApiEvent } from "@/types/evenement";

interface EventModalProps {
  event: ApiEvent;
  onClose(): void;
}

export default function EventModal({ event, onClose }: EventModalProps) {
  useEffect(() => {
    const esc = (e: KeyboardEvent) => e.key === "Escape" && onClose();
    window.addEventListener("keydown", esc);
    return () => window.removeEventListener("keydown", esc);
  }, [onClose]);

  return (
    <div
      className="absolute inset-0 z-50 flex items-center justify-center bg-black/40"
      onClick={(e) => e.target === e.currentTarget && onClose()}
    >
      <motion.div
        initial={{ opacity: 0, scale: 0.95 }}
        animate={{ opacity: 1, scale: 1 }}
        transition={{ duration: 0.25 }}
        className="relative w-full max-w-2xl bg-base-100 rounded-lg p-6 shadow-xl"
        onClick={(e) => e.stopPropagation()}
      >
        <button
          className="btn btn-sm btn-circle absolute top-2 right-2"
          onClick={onClose}
        >
          <XIcon size={18} />
        </button>
        {event.image && (
          <img
            src={event.image}
            alt={event.titre}
            className="w-full h-64 object-cover rounded-md mb-4"
          />
        )}
        <h2 className="text-2xl font-bold mb-2">{event.titre}</h2>
        <p className="mb-4 whitespace-pre-line text-sm opacity-80">
          {event.description}
        </p>
        <div className="flex justify-between items-center text-sm">
          <div className="flex items-center gap-2">
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

          <div className="flex items-center gap-2">
            <CalendarIcon size={18} />
            {new Date(event.date_fin).toLocaleString(undefined, {
              weekday: "short",
              day: "numeric",
              month: "short",
              year: "numeric",
              hour: "2-digit",
              minute: "2-digit",
            })}
          </div>
        </div>
      </motion.div>
    </div>
  );
}
