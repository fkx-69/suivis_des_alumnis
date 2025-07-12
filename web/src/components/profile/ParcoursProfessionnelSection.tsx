"use client";
import { useState, useRef } from "react";
import { Input } from "@/components/ui/Input";
import { Pencil, Plus, Trash2 } from "lucide-react";
import {
  createParcoursProfessionnel,
  updateParcoursProfessionnel,
  deleteParcoursProfessionnel,
} from "@/lib/api/parcours";
import { ParcoursProfessionnel } from "@/types/parcours";

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
  const [editing, setEditing] = useState<ParcoursProfessionnel | null>(null);
  const [form, setForm] = useState({
    poste: "",
    entreprise: "",
    date_debut: "",
    type_contrat: contrats[0].value,
  });
  const dialogRef = useRef<HTMLDialogElement>(null);

  const openCreate = () => {
    setEditing(null);
    setForm({ poste: "", entreprise: "", date_debut: "", type_contrat: contrats[0].value });
    dialogRef.current?.showModal();
  };

  const openEdit = (item: ParcoursProfessionnel) => {
    setEditing(item);
    setForm({
      poste: item.poste,
      entreprise: item.entreprise,
      date_debut: item.date_debut,
      type_contrat: item.type_contrat,
    });
    dialogRef.current?.showModal();
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
    dialogRef.current?.close();
    onChanged();
  };

  const handleDelete = async (id: number) => {
    await deleteParcoursProfessionnel(id);
    onChanged();
  };

  return (
    <div className="bg-base-100 p-6 rounded-2xl shadow-lg">
      <div className="flex justify-between items-center mb-4">
        <h2 className="text-2xl font-bold">Parcours Professionnel</h2>
        <button className="btn btn-primary btn-sm" onClick={openCreate}>
          <Plus size={18} className="mr-1" />
          Ajouter
        </button>
      </div>
      <div className="space-y-4">
        {items.map((p) => (
          <div key={p.id} className="p-4 rounded-lg bg-base-200 flex justify-between items-start">
            <div>
              <p className="font-semibold text-lg">{p.poste}</p>
              <p className="text-base-content/80">{p.entreprise}</p>
              <p className="text-sm text-base-content/60">Depuis {new Date(p.date_debut).toLocaleDateString()} - {p.type_contrat}</p>
            </div>
            <div className="flex gap-2 items-center">
              <button className="btn btn-ghost btn-sm btn-circle" onClick={() => openEdit(p)}>
                <Pencil size={16} />
              </button>
              <button className="btn btn-ghost btn-sm btn-circle text-error" onClick={() => handleDelete(p.id)}>
                <Trash2 size={16} />
              </button>
            </div>
          </div>
        ))}
        {items.length === 0 && (
          <p className="text-center text-base-content/60 py-4">Aucun parcours professionnel n&apos;a été ajouté pour le moment.</p>
        )}
      </div>

      <dialog ref={dialogRef} className="modal">
        <div className="modal-box">
          <form method="dialog">
            <button className="btn btn-sm btn-circle btn-ghost absolute right-2 top-2">✕</button>
          </form>
          <h3 className="font-bold text-lg mb-4">
            {editing ? "Modifier le parcours" : "Ajouter un parcours"} professionnel
          </h3>
          <form onSubmit={handleSubmit} className="space-y-4">
            <Input name="poste" value={form.poste} onChange={handleChange} placeholder="Poste" required />
            <Input name="entreprise" value={form.entreprise} onChange={handleChange} placeholder="Entreprise" required />
            <Input name="date_debut" type="date" value={form.date_debut} onChange={handleChange} placeholder="Date de début" required />
            <select name="type_contrat" value={form.type_contrat} className="select select-bordered w-full" onChange={handleChange}>
              {contrats.map((c) => (
                <option key={c.value} value={c.value}>{c.label}</option>
              ))}
            </select>
            <div className="modal-action">
              <button type="submit" className="btn btn-primary">
                {editing ? "Enregistrer" : "Ajouter"}
              </button>
            </div>
          </form>
        </div>
      </dialog>
    </div>
  );
}
