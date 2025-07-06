"use client";
import { useState, useRef } from "react";
import { Input } from "@/components/ui/Input";
import { Pencil, Plus, Trash2 } from "lucide-react";
import {
  createParcoursAcademique,
  updateParcoursAcademique,
  deleteParcoursAcademique,
} from "@/lib/api/parcours";
import type { ParcoursAcademique } from "@/types/parcours";
import { Mention, Mentions } from "@/lib/constants/parcours";

interface Props {
  items: ParcoursAcademique[];
  onChanged: () => void;
}

interface ParcoursAcademiqueForm {
  diplome: string;
  institution: string;
  annee_obtention: string;
  mention: Mention | "";
}

export default function ParcoursAcademiqueSection({ items, onChanged }: Props) {
  const [editing, setEditing] = useState<ParcoursAcademique | null>(null);
  const [form, setForm] = useState<ParcoursAcademiqueForm>({
    diplome: "",
    institution: "",
    annee_obtention: "",
    mention: "",
  });
  const dialogRef = useRef<HTMLDialogElement>(null);

  const openCreate = () => {
    setEditing(null);
    setForm({ diplome: "", institution: "", annee_obtention: "", mention: "" });
    dialogRef.current?.showModal();
  };

  const openEdit = (item: ParcoursAcademique) => {
    setEditing(item);
    setForm({
      diplome: item.diplome,
      institution: item.institution,
      annee_obtention: String(item.annee_obtention),
      mention: item.mention ? `mention_${item.mention}` : "",
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
    dialogRef.current?.close();
    onChanged();
  };

  const handleDelete = async (id: number) => {
    await deleteParcoursAcademique(id);
    onChanged();
  };

  return (
    <div className="bg-base-100 p-6 rounded-2xl shadow-lg">
      <div className="flex justify-between items-center mb-4">
        <h2 className="text-2xl font-bold">Parcours Académique</h2>
        <button className="btn btn-primary btn-sm" onClick={openCreate}>
          <Plus size={18} className="mr-1" />
          Ajouter
        </button>
      </div>
      <div className="space-y-4">
        {items.map((p) => (
          <div
            key={p.id}
            className="p-4 rounded-lg bg-base-200 flex justify-between items-start"
          >
            <div>
              <p className="font-semibold text-lg">{p.diplome}</p>
              <p className="text-base-content/80">{p.institution}</p>
              <p className="text-sm text-base-content/60">
                Obtenu en {p.annee_obtention}{" "}
                {p.mention && `- Mention ${Mentions[`mention_${p.mention}` as keyof typeof Mentions]}`}
              </p>
            </div>
            <div className="flex gap-2 items-center">
              <button
                className="btn btn-ghost btn-sm btn-circle"
                onClick={() => openEdit(p)}
              >
                <Pencil size={16} />
              </button>
              <button
                className="btn btn-ghost btn-sm btn-circle text-error"
                onClick={() => handleDelete(p.id)}
              >
                <Trash2 size={16} />
              </button>
            </div>
          </div>
        ))}
        {items.length === 0 && (
          <p className="text-center text-base-content/60 py-4">
            Aucun parcours académique n'a été ajouté pour le moment.
          </p>
        )}
      </div>

      <dialog ref={dialogRef} className="modal">
        <div className="modal-box">
          <form method="dialog">
            <button className="btn btn-sm btn-circle btn-ghost absolute right-2 top-2">
              ✕
            </button>
          </form>
          <h3 className="font-bold text-lg mb-4">
            {editing ? "Modifier le parcours" : "Ajouter un parcours"}{" "}
            académique
          </h3>
          <form onSubmit={handleSubmit} className="space-y-4">
            <Input
              name="diplome"
              value={form.diplome}
              onChange={handleChange}
              placeholder="Diplôme"
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
            <select
              name="mention"
              value={form.mention}
              className="select select-bordered w-full"
              onChange={handleChange}
            >
              <option value="">Sélectionnez une mention (optionnel)</option>
              {Object.entries(Mentions).map(([key, value]) => (
                <option key={key} value={key}>
                  {value}
                </option>
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
