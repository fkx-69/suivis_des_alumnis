import { XIcon, Image as ImageIcon } from "lucide-react";
import { Input } from "@/components/ui/Input";
import { motion } from "framer-motion";
import Image from "next/image";
import { useEffect, useState, useRef } from "react";
import { createGroup } from "@/lib/api/group";
import { Group } from "@/types/group";

interface AddGroupModalProps {
  onClose(): void;
  onCreated?: (group: Group) => void;
}

export default function AddGroupModal({
  onClose,
  onCreated,
}: AddGroupModalProps) {
  const [form, setForm] = useState({ nom_groupe: "", description: "" });
  const [image, setImage] = useState<File | null>(null);
  const [imagePreview, setImagePreview] = useState<string | null>(null);
  const fileInputRef = useRef<HTMLInputElement>(null);
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleChange = (
    e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>
  ) => {
    const { name, value } = e.target;
    setForm((f) => ({ ...f, [name]: value }));
  };

  const handleImageChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      setImage(file);
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
      const group = await createGroup({ ...form, image });
      onCreated?.(group);
      setForm({ nom_groupe: "", description: "" });
      setImage(null);
      setImagePreview(null);
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

  return (
    <div
      className="absolute inset-0 z-50 flex items-center justify-center bg-black/40"
      onClick={onClose}
    >
      <motion.form
        initial={{ opacity: 0, scale: 0.95 }}
        animate={{ opacity: 1, scale: 1 }}
        transition={{ duration: 0.25 }}
        className="relative w-full max-w-lg bg-base-100 rounded-lg p-6 shadow-xl space-y-4"
        onClick={(e) => e.stopPropagation()}
        onSubmit={handleSubmit}
      >
        <button
          type="button"
          className="btn btn-sm btn-circle absolute top-2 right-2 z-10"
          onClick={onClose}
        >
          <XIcon size={18} />
        </button>
        {error && <div className="alert alert-error">{error}</div>}

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

        <div className="modal-action justify-between items-center mt-4">
          <button
            type="button"
            onClick={() => fileInputRef.current?.click()}
            className="btn btn-ghost btn-sm gap-2"
          >
            <ImageIcon size={18} /> Photo
          </button>
          <button
            className="btn btn-primary"
            disabled={submitting}
            type="submit"
          >
            {submitting ? <span className="loading loading-spinner"></span> : "Créer le groupe"}
          </button>
        </div>

        <input
          type="file"
          ref={fileInputRef}
          className="hidden"
          accept="image/*"
          onChange={handleImageChange}
        />
      </motion.form>
    </div>
  );
}
