"use client";
import { XIcon } from "lucide-react";
import { Input } from "@/components/ui/Input";
import { motion } from "framer-motion";
import { useEffect, useState } from "react";
import { createGroup } from "@/lib/api/group";
import { Group } from "@/types/group";

interface AddGroupModalProps {
  onClose(): void;
  onCreated?: (group: Group) => void;
}

export default function AddGroupModal({ onClose, onCreated }: AddGroupModalProps) {
  const [form, setForm] = useState({ nom_groupe: "", description: "" });
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
    const { name, value } = e.target;
    setForm((f) => ({ ...f, [name]: value }));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setSubmitting(true);
    setError(null);
    try {
      const group = await createGroup(form);
      onCreated?.(group);
      setForm({ nom_groupe: "", description: "" });
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

  return (
    <div className="absolute inset-0 z-50 flex items-center justify-center bg-black/40" onClick={onClose}>
      <motion.form
        initial={{ opacity: 0, scale: 0.95 }}
        animate={{ opacity: 1, scale: 1 }}
        transition={{ duration: 0.25 }}
        className="relative w-full max-w-lg bg-base-100 rounded-lg p-6 shadow-xl space-y-4"
        onClick={(e) => e.stopPropagation()}
        onSubmit={handleSubmit}
      >
        <button type="button" className="btn btn-sm btn-circle absolute top-2 right-2" onClick={onClose}>
          <XIcon size={18} />
        </button>
        {error && <div className="alert alert-error">{error}</div>}
        <Input
          name="nom_groupe"
          value={form.nom_groupe}
          onChange={handleChange}
          placeholder="Nom du groupe"
          required
          className="input-ghost"
        />
        <textarea
          name="description"
          value={form.description}
          onChange={handleChange}
          placeholder="Description"
          required
          className="textarea textarea-ghost w-full h-32"
        />
        <button className="btn btn-primary" disabled={submitting} type="submit">
          Créer le groupe
        </button>
      </motion.form>
    </div>
  );
}
