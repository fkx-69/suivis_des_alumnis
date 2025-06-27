"use client";
import { CalendarIcon, XIcon } from "lucide-react";
import { Input } from "@/components/ui/Input";
import { motion } from "framer-motion";
import { useEffect, useRef, useState } from "react";
import { createEvent } from "@/lib/api/evenement";
import { ApiEvent } from "@/types/evenement";

interface AddEventModalProps {
  onClose(): void;
  onCreated?: (event: ApiEvent) => void;
}

export default function AddEventModal({
  onClose,
  onCreated,
}: AddEventModalProps) {
  const [form, setForm] = useState({
    titre: "",
    description: "",
    date_debut: "",
    date_fin: "",
    image: undefined as File | undefined,
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

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files) {
      setForm((f) => ({ ...f, image: e.target.files?.[0] }));
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setSubmitting(true);
    setError(null);
    try {
      const newEvent = await createEvent(form);
      onCreated?.(newEvent);
      setForm({ titre: "", description: "", date_debut: "", date_fin: "", image: undefined });
      onClose();
    } catch (err: any) {
      setError(err.message);
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
    <div className="absolute inset-0 z-50 flex items-center justify-center bg-black/40">
      <motion.form
        role="dialog"
        aria-modal="true"
        aria-labelledby="add-event-modal-title"
        initial={{ opacity: 0, scale: 0.95 }}
        animate={{ opacity: 1, scale: 1 }}
        transition={{ duration: 0.25 }}
        className="relative w-full max-w-2xl bg-base-100 rounded-lg p-6 shadow-xl space-y-4"
        onClick={(e) => e.stopPropagation()}
        onSubmit={handleSubmit}
      >
        <button
          className="btn btn-sm btn-circle absolute top-2 right-2"
          type="button"
          onClick={onClose}
        >
          <XIcon size={18} />
        </button>
        <h2 id="add-event-modal-title" className="sr-only">
          Créer un évènement
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
        <Input
          type="file"
          name="image"
          onChange={handleFileChange}
          className="input-ghost"
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
          Créer l'évènement
        </button>
      </motion.form>
    </div>
  );
}
