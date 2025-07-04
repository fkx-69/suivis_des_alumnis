"use client";
import { useState, useRef, useEffect } from "react";
import { Input } from "@/components/ui/Input";
import { Pencil, Trash2 } from "lucide-react";
import {
  createParcoursProfessionnel,
  updateParcoursProfessionnel,
  deleteParcoursProfessionnel,
} from "@/lib/api/parcours";
import { ParcoursProfessionnel } from "@/types/parcours";
import { motion } from "framer-motion";

interface Props {
  items: ParcoursProfessionnel[];
  onChanged: () => void;
}

const contrats = [
  { value: "CDI", label: "CDI" },
  { value: "CDD", label: "CDD" },
  { value: "stage", label: "Stage" },
  { value: "freelance", label: "Freelance" },
  { value: "autre", label: "Autre" },
];

export default function ParcoursProfessionnelSection({ items, onChanged }: Props) {
  const [showModal, setShowModal] = useState(false);
  const [editing, setEditing] = useState<ParcoursProfessionnel | null>(null);
  const [form, setForm] = useState({
    poste: "",
    entreprise: "",
    date_debut: "",
    type_contrat: contrats[0].value,
  });
  const firstFieldRef = useRef<HTMLInputElement>(null);

  const openCreate = () => {
    setEditing(null);
    setForm({ poste: "", entreprise: "", date_debut: "", type_contrat: contrats[0].value });
    setShowModal(true);
  };
  const openEdit = (item: ParcoursProfessionnel) => {
    setEditing(item);
    setForm({
      poste: item.poste,
      entreprise: item.entreprise,
      date_debut: item.date_debut,
      type_contrat: item.type_contrat,
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
    const payload = { ...form } as Omit<ParcoursProfessionnel, "id">;
    if (editing) {
      await updateParcoursProfessionnel(editing.id, payload);
    } else {
      await createParcoursProfessionnel(payload);
    }
    setShowModal(false);
    onChanged();
  };

  const handleDelete = async (id: number) => {
    await deleteParcoursProfessionnel(id);
    onChanged();
  };

  useEffect(() => {
    if (showModal) firstFieldRef.current?.focus();
  }, [showModal]);

  return (
    <div className="space-y-2">
      <div className="flex justify-between items-center">
        <h2 className="text-xl font-semibold">Professionnel</h2>
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
              {p.poste} - {p.entreprise}
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
              {editing ? "Modifier" : "Ajouter"} un parcours professionnel
            </h3>
            <Input
              name="poste"
              value={form.poste}
              onChange={handleChange}
              placeholder="Poste"
              ref={firstFieldRef}
              required
            />
            <Input
              name="entreprise"
              value={form.entreprise}
              onChange={handleChange}
              placeholder="Entreprise"
              required
            />
            <Input
              name="date_debut"
              type="date"
              value={form.date_debut}
              onChange={handleChange}
              placeholder="Date début"
              required
            />
            <label className="block text-base-content">
              <span>Type de contrat</span>
              <select
                name="type_contrat"
                value={form.type_contrat}
                onChange={handleChange}
                className="select select-bordered w-full mt-1"
              >
                {contrats.map((c) => (
                  <option key={c.value} value={c.value}>
                    {c.label}
                  </option>
                ))}
              </select>
            </label>
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
