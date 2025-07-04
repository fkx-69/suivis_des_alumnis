import { useState } from "react";
import { api } from "@/lib/api/axios";
import EventCard from "./EventCard";
import { Input } from "@/components/ui/Input";

export interface AddEventFormProps {
  onCreated?: (event: any) => void;
}

export default function AddEventForm({ onCreated }: AddEventFormProps) {
  const [form, setForm] = useState({
    titre: "",
    description: "",
    date_debut: "",
    date_fin: "",
  });
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

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
      const res = await api.post("/events/evenements/creer/", form);
      if (res.status >= 200 && res.status < 300) {
        onCreated?.(res.data);
        setForm({ titre: "", description: "", date_debut: "", date_fin: "" });
      } else {
        setError("Erreur lors de la création.");
      }
    } catch (err: any) {
      setError(err.message);
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="mb-6 space-y-4">
      {error && <div className="alert alert-error">{error}</div>}
      <Input
        label="Titre"
        name="titre"
        value={form.titre}
        onChange={handleChange}
        required
      />
      <label className="block">
        <span>Description</span>
        <textarea
          name="description"
          className="textarea textarea-bordered w-full"
          value={form.description}
          onChange={handleChange}
          required
        />
      </label>
      <Input
        label="Date début"
        type="datetime-local"
        name="date_debut"
        value={form.date_debut}
        onChange={handleChange}
        required
      />
      <Input
        label="Date fin"
        type="datetime-local"
        name="date_fin"
        value={form.date_fin}
        onChange={handleChange}
        required
      />
      <button className="btn btn-primary" disabled={submitting} type="submit">
        Créer l'évènement
      </button>
      <div className="mt-6">
        <span className="font-bold mb-2 block">Prévisualisation :</span>
        <EventCard event={{ ...form }} />
      </div>
    </form>
  );
}
