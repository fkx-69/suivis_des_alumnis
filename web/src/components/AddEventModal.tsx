import { CalendarIcon, XIcon, Image as ImageIcon } from "lucide-react";
import { Input } from "@/components/ui/Input";
import { motion } from "framer-motion";
import Image from "next/image";
import { useEffect, useRef, useState } from "react";
import { createEvent, updateEvent } from "@/lib/api/evenement";
import { ApiEvent } from "@/types/evenement";

interface AddEventModalProps {
  event?: ApiEvent;
  onClose(): void;
  onCreated?: (event: ApiEvent) => void;
  onUpdated?: (event: ApiEvent) => void;
}

export default function AddEventModal({
  event,
  onClose,
  onCreated,
  onUpdated,
}: AddEventModalProps) {
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
  const formatForInput = (date: Date) => {
    const year = date.getFullYear();
    const month = (date.getMonth() + 1).toString().padStart(2, "0");
    const day = date.getDate().toString().padStart(2, "0");
    const hours = date.getHours().toString().padStart(2, "0");
    const minutes = date.getMinutes().toString().padStart(2, "0");
    return `${year}-${month}-${day}T${hours}:${minutes}`;
  };

  const tomorrow = new Date();
  tomorrow.setDate(tomorrow.getDate() + 1);
  tomorrow.setHours(0, 0, 0, 0);
  const minStartDate = formatForInput(tomorrow);

  const [form, setForm] = useState({
    titre: event?.titre ?? "",
    description: event?.description ?? "",
    date_debut: event ? toDatetimeLocal(event.date_debut) : "",
    date_fin: event ? toDatetimeLocal(event.date_fin) : "",
    image: undefined as File | undefined,
  });
  const [imagePreview, setImagePreview] = useState<string | null>(
    event?.image ?? null
  );
  const fileInputRef = useRef<HTMLInputElement>(null);
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
    const file = e.target.files?.[0];
    if (file) {
      setForm((f) => ({ ...f, image: file }));
      const reader = new FileReader();
      reader.onloadend = () => {
        setImagePreview(reader.result as string);
      };
      reader.readAsDataURL(file);
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setSubmitting(true);
    setError(null);
    const start = new Date(form.date_debut);
    const end = new Date(form.date_fin);
    if (isNaN(start.getTime()) || isNaN(end.getTime())) {
      setSubmitting(false);
      setError("Dates invalides");
      return;
    }
    if (start < tomorrow) {
      setSubmitting(false);
      setError(
        "La date de début doit être au moins le lendemain du jour courant."
      );
      return;
    }
    if (end <= start) {
      setSubmitting(false);
      setError("La date de fin doit être après la date de début.");
      return;
    }
    try {
      if (event) {
        const updated = await updateEvent(event.id, {
          titre: form.titre,
          description: form.description,
          date_debut: form.date_debut,
          date_fin: form.date_fin,
        });
        onUpdated?.(updated);
      } else {
        const newEvent = await createEvent(form);
        onCreated?.(newEvent);
        setForm({
          titre: "",
          description: "",
          date_debut: "",
          date_fin: "",
          image: undefined,
        });
        setImagePreview(null);
        if (fileInputRef.current) fileInputRef.current.value = "";
      }
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
    <div className="absolute inset-0 z-50 flex items-center justify-center bg-black/40" onClick={onClose}>
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
        <h2 id="add-event-modal-title" className="sr-only">
          {event ? "Modifier l'évènement" : "Créer un évènement"}
        </h2>
        {imagePreview && (
          <div className="relative rounded-lg overflow-hidden border border-base-300/50">
            <button
              type="button"
              className="btn btn-sm btn-circle absolute top-2 right-2 z-10"
              onClick={() => {
                setForm((f) => ({ ...f, image: undefined }));
                setImagePreview(null);
                if (fileInputRef.current) fileInputRef.current.value = "";
              }}
            >
              <XIcon size={18} />
            </button>
            <Image
              src={imagePreview}
              alt="Aperçu"
              width={500}
              height={192}
              className="w-full h-48 object-cover"
            />
          </div>
        )}
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
              min={minStartDate}
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
              min={form.date_debut || minStartDate}
            />
          </div>
        </div>
        <div className="modal-action justify-between items-center mt-4">
          {!event && (
            <button
              type="button"
              onClick={() => fileInputRef.current?.click()}
              className="btn btn-ghost btn-sm gap-2"
            >
              <ImageIcon size={18} /> Photo
            </button>
          )}
          <button
            className="btn btn-primary"
            disabled={submitting}
            type="submit"
          >
            {submitting ? (
              <span className="loading loading-spinner"></span>
            ) : event ? (
              "Modifier l'évènement"
            ) : (
              "Créer l'évènement"
            )}
          </button>
        </div>
        {!event && (
          <input
            type="file"
            ref={fileInputRef}
            className="hidden"
            accept="image/*"
            onChange={handleFileChange}
          />
        )}
      </motion.form>
    </div>
  );
}
