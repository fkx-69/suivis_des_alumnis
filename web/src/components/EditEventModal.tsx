import { CalendarIcon } from "lucide-react";
import { Input } from "@/components/ui/Input";
import { motion } from "framer-motion";
import { useEffect, useRef, useState } from "react";
import { updateEvent } from "@/lib/api/evenement";
import { ApiEvent } from "@/types/evenement";

interface EditEventModalProps {
  event: ApiEvent;
  onClose(): void;
  onUpdated?: (event: ApiEvent) => void;
}

const toDatetimeLocal = (dateStr: string) => {
  const date = new Date(dateStr);
  if (isNaN(date.getTime())) return "";
  const year = date.getFullYear();
  const month = (date.getMonth() + 1).toString().padStart(2, "0");
  const day = date.getDate().toString().padStart(2, "0");
  const hours = date.getHours().toString().padStart(2, "0");
  const minutes = date.getMinutes().toString().padStart(2, "0");
  return `${year}-${month}-${day}T${hours}:${minutes}`;
};

export default function EditEventModal({
  event,
  onClose,
  onUpdated,
}: EditEventModalProps) {
  const [form, setForm] = useState({
    titre: event.titre,
    description: event.description,
    date_debut: toDatetimeLocal(event.date_debut),
    date_fin: toDatetimeLocal(event.date_fin),
  });
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const firstFieldRef = useRef<HTMLInputElement>(null);

  const handleChange = (
    e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>
  ) => {
    const { name, value } = e.target;
    setForm((f) => ({ ...f, [name]: value }));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setSubmitting(true);
    setError(null);
    try {
      const updatedEvent = await updateEvent(event.id, form);
      onUpdated?.(updatedEvent);
      onClose();
    } catch (err: unknown) {
      if (err instanceof Error) {
        setError(err.message);
      } else {
        setError("Une erreur inconnue est survenue.");
      }
    } finally {
      setSubmitting(false);
    }
  };

  useEffect(() => {
    const esc = (e: KeyboardEvent) => e.key === "Escape" && onClose();
    window.addEventListener("keydown", esc);
    return () => window.removeEventListener("keydown", esc);
  }, [onClose]);

  useEffect(() => {
    firstFieldRef.current?.focus();
  }, []);

  return (
    <div
      className="absolute inset-0 z-50 flex items-center justify-center bg-black/40"
      onClick={(e) => e.target === e.currentTarget && onClose()}
    >
      <motion.form
        role="dialog"
        aria-modal="true"
        aria-labelledby="edit-event-modal-title"
        initial={{ opacity: 0, scale: 0.95 }}
        animate={{ opacity: 1, scale: 1 }}
        transition={{ duration: 0.25 }}
        className="relative w-full max-w-2xl bg-base-100 rounded-lg p-6 shadow-xl space-y-4"
        onClick={(e) => e.stopPropagation()}
        onSubmit={handleSubmit}
      >
        <h2 id="edit-event-modal-title" className="sr-only">
          Modifier l&apos;évènement
        </h2>
        {error && <div className="alert alert-error">{error}</div>}
        <Input
          name="titre"
          value={form.titre}
          onChange={handleChange}
          placeholder="Titre"
          required
          className="input-ghost text-2xl font-bold"
          ref={firstFieldRef}
        />
        <textarea
          name="description"
          value={form.description}
          onChange={handleChange}
          placeholder="Description"
          required
          className="textarea textarea-ghost w-full text-sm opacity-80 h-32"
        />
        <div className="flex justify-between items-center text-sm gap-4 flex-wrap">
          <div className="flex items-center gap-2 flex-1 min-w-[10rem]">
            <CalendarIcon size={18} />
            <Input
              type="datetime-local"
              name="date_debut"
              value={form.date_debut}
              onChange={handleChange}
              required
              className="input-ghost"
            />
          </div>
          <div className="flex items-center gap-2 flex-1 min-w-[10rem]">
            <CalendarIcon size={18} />
            <Input
              type="datetime-local"
              name="date_fin"
              value={form.date_fin}
              onChange={handleChange}
              required
              className="input-ghost"
            />
          </div>
        </div>
        <button className="btn btn-primary" disabled={submitting} type="submit">
          Modifier l&apos;évènement
        </button>
      </motion.form>
    </div>
  );
}
