import { CalendarIcon, XIcon, Image as ImageIcon } from "lucide-react";
import { Input } from "@/components/ui/Input";
import { motion } from "framer-motion";
import Image from "next/image";
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
  const [imagePreview, setImagePreview] = useState<string | null>(null);
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
    try {
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
          className="btn btn-sm btn-circle absolute top-2 right-2 z-10"
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
        {imagePreview && (
          <div className="rounded-lg overflow-hidden border border-base-300/50">
            <Image
              src={imagePreview}
              alt="Aperçu"
              width={500}
              height={192}
              className="w-full h-48 object-cover"
            />
          </div>
        )}
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
        <div className="modal-action justify-between items-center mt-4">
          <button
            type="button"
            onClick={() => fileInputRef.current?.click()}
            className="btn btn-ghost btn-sm gap-2"
          >
            <ImageIcon size={18} /> Photo
          </button>
          <button className="btn btn-primary" disabled={submitting} type="submit">
            {submitting ? (
              <span className="loading loading-spinner"></span>
            ) : (
              "Créer l'évènement"
            )}
          </button>
        </div>

        <input
          type="file"
          ref={fileInputRef}
          className="hidden"
          accept="image/*"
          onChange={handleFileChange}
        />
      </motion.form>
    </div>
  );
}
