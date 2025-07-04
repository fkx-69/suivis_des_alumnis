"use client";
import { useState, useRef, useEffect } from "react";
import { Input } from "@/components/ui/Input";
import { Pencil, Trash2 } from "lucide-react";
import {
  createParcoursAcademique,
  updateParcoursAcademique,
  deleteParcoursAcademique,
} from "@/lib/api/parcours";
import { ParcoursAcademique } from "@/types/parcours";
import { motion } from "framer-motion";

interface Props {
  items: ParcoursAcademique[];
  onChanged: () => void;
}

export default function ParcoursAcademiqueSection({ items, onChanged }: Props) {
  const [showModal, setShowModal] = useState(false);
  const [editing, setEditing] = useState<ParcoursAcademique | null>(null);
  const [form, setForm] = useState({
    diplome: "",
    institution: "",
    annee_obtention: "",
    mention: "",
  });
  const firstFieldRef = useRef<HTMLInputElement>(null);

  const openCreate = () => {
    setEditing(null);
    setForm({ diplome: "", institution: "", annee_obtention: "", mention: "" });
    setShowModal(true);
  };
  const openEdit = (item: ParcoursAcademique) => {
    setEditing(item);
    setForm({
      diplome: item.diplome,
      institution: item.institution,
      annee_obtention: String(item.annee_obtention),
      mention: item.mention ?? "",
    });
    setShowModal(true);
  };

  const handleChange = (
    e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>
  ) => {
    const { name, value } = e.target;
    setForm((f) => ({ ...f, [name]: value }));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    const payload = {
      diplome: form.diplome,
      institution: form.institution,
      annee_obtention: parseInt(form.annee_obtention, 10),
      mention: form.mention || null,
    } as Omit<ParcoursAcademique, "id">;
    if (editing) {
      await updateParcoursAcademique(editing.id, payload);
    } else {
      await createParcoursAcademique(payload);
    }
    setShowModal(false);
    onChanged();
  };

  const handleDelete = async (id: number) => {
    await deleteParcoursAcademique(id);
    onChanged();
  };

  useEffect(() => {
    if (showModal) firstFieldRef.current?.focus();
  }, [showModal]);

  return (
    <div className="space-y-2">
      <div className="flex justify-between items-center">
        <h2 className="text-xl font-semibold">Académique</h2>
        <button className="btn btn-sm btn-primary" onClick={openCreate}>
          Ajouter
        </button>
      </div>
      <ul className="space-y-1">
        {items.map((p) => (
          <li
            key={p.id}
            className="bg-base-200 rounded-md p-2 flex justify-between items-center"
          >
            <span>
              {p.diplome} - {p.institution} ({p.annee_obtention})
            </span>
            <span className="flex gap-2">
              <button
                className="btn btn-xs btn-circle"
                onClick={() => openEdit(p)}
              >
                <Pencil size={14} />
              </button>
              <button
                className="btn btn-xs btn-circle btn-error"
                onClick={() => handleDelete(p.id)}
              >
                <Trash2 size={14} />
              </button>
            </span>
          </li>
        ))}
      </ul>

      {showModal && (
        <div
          className="absolute inset-0 z-50 flex items-center justify-center bg-black/40"
          onClick={() => setShowModal(false)}
        >
          <motion.form
            initial={{ opacity: 0, scale: 0.95 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ duration: 0.25 }}
            className="bg-base-100 p-6 rounded-lg space-y-4 w-full max-w-sm"
            onClick={(e) => e.stopPropagation()}
            onSubmit={handleSubmit}
          >
            <h3 className="text-lg font-semibold mb-2">
              {editing ? "Modifier" : "Ajouter"} un parcours académique
            </h3>
            <Input
              name="diplome"
              value={form.diplome}
              onChange={handleChange}
              placeholder="Diplôme"
              ref={firstFieldRef}
              required
            />
            <Input
              name="institution"
              value={form.institution}
              onChange={handleChange}
              placeholder="Institution"
              required
            />
            <Input
              name="annee_obtention"
              type="number"
              value={form.annee_obtention}
              onChange={handleChange}
              placeholder="Année d'obtention"
              required
            />
            <Input
              name="mention"
              value={form.mention}
              onChange={handleChange}
              placeholder="Mention"
            />
            <div className="flex justify-end gap-2 pt-2">
              <button
                type="button"
                className="btn btn-ghost btn-sm"
                onClick={() => setShowModal(false)}
              >
                Annuler
              </button>
              <button type="submit" className="btn btn-primary btn-sm">
                {editing ? "Modifier" : "Créer"}
              </button>
            </div>
          </motion.form>
        </div>
      )}
    </div>
  );
}
