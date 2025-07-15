"use client";
import { useState, useRef } from "react";
import { Input } from "@/components/ui/Input";
import { Pencil, Plus, Trash2 } from "lucide-react";
import {
  createParcoursAcademique,
  updateParcoursAcademique,
  deleteParcoursAcademique,
  createParcoursProfessionnel,
  updateParcoursProfessionnel,
  deleteParcoursProfessionnel,
} from "@/lib/api/parcours";
import type {
  ParcoursAcademique,
  ParcoursProfessionnel,
} from "@/types/parcours";
import { Mentions } from "@/lib/constants/parcours";
import type { Mention_keys } from "@/types/parcours";

interface Props {
  academicItems: ParcoursAcademique[];
  professionalItems: ParcoursProfessionnel[];
  onChanged: () => void;
}

const contrats = [
  { value: "CDI", label: "CDI" },
  { value: "CDD", label: "CDD" },
  { value: "stage", label: "Stage" },
  { value: "freelance", label: "Freelance" },
  { value: "autre", label: "Autre" },
];

const initialAcademicForm = {
  diplome: "",
  institution: "",
  annee_obtention: "",
  mention: null as Mention | null,
};

const initialProfessionalForm = {
  poste: "",
  entreprise: "",
  date_debut: "",
  type_contrat: contrats[0].value,
};

interface AcademicForm {
  diplome: string;
  institution: string;
  annee_obtention: string;
  mention: Mention | null;
}

interface ProfessionalForm {
  poste: string;
  entreprise: string;
  date_debut: string;
  type_contrat: string;
}

type FormValues = AcademicForm | ProfessionalForm;

interface ParcoursItemProps {
  item: ParcoursAcademique | ParcoursProfessionnel;
  onDelete: (id: number, type: "academic" | "professional") => void;
  onEdit: (item: ParcoursAcademique | ParcoursProfessionnel) => void;
}

const ParcoursItem = ({ item, onDelete, onEdit }: ParcoursItemProps) => {
  const isAcademic = "diplome" in item;

  return (
    <div
      key={isAcademic ? `ac-${item.id}` : `pro-${item.id}`}
      className="p-4 rounded-lg bg-base-200 flex justify-between items-start"
    >
      <div>
        {isAcademic ? (
          <>
            <p className="font-semibold text-lg">{item.diplome}</p>
            <p className="text-base-content/80">{item.institution}</p>
            <p className="text-sm text-base-content/60">
              Obtenu en {item.annee_obtention}{" "}
              {item.mention &&
                `- Mention ${Mentions[`mention_${item.mention}` as keyof typeof Mentions]}`}
            </p>
          </>
        ) : (
          <>
            <p className="font-semibold text-lg">
              {(item as ParcoursProfessionnel).poste}
            </p>
            <p className="text-base-content/80">
              {(item as ParcoursProfessionnel).entreprise}
            </p>
            <p className="text-sm text-base-content/60">
              Depuis{" "}
              {new Date(
                (item as ParcoursProfessionnel).date_debut
              ).toLocaleDateString()}{" "}
              - {(item as ParcoursProfessionnel).type_contrat}
            </p>
          </>
        )}
      </div>
      <div className="flex gap-2 items-center">
        <button
          className="btn btn-ghost btn-sm btn-circle"
          onClick={() => onEdit(item)}
        >
          <Pencil size={16} />
        </button>
        <button
          className="btn btn-ghost btn-sm btn-circle text-error"
          onClick={() =>
            onDelete(item.id, isAcademic ? "academic" : "professional")
          }
        >
          <Trash2 size={16} />
        </button>
      </div>
    </div>
  );
};

export default function ParcoursSection({
  academicItems,
  professionalItems,
  onChanged,
}: Props) {
  const [editing, setEditing] = useState<
    ParcoursAcademique | ParcoursProfessionnel | null
  >(null);
  const [formType, setFormType] = useState<"academic" | "professional" | null>(
    null
  );
  const [form, setForm] = useState<FormValues>(initialAcademicForm);
  const dialogRef = useRef<HTMLDialogElement>(null);

  const openCreate = (type: "academic" | "professional") => {
    setEditing(null);
    setFormType(type);
    setForm(
      type === "academic" ? initialAcademicForm : initialProfessionalForm
    );
    dialogRef.current?.showModal();
  };

  const openEdit = (item: ParcoursAcademique | ParcoursProfessionnel) => {
    setEditing(item);
    if ("diplome" in item) {
      setFormType("academic");
      setForm({
        diplome: item.diplome,
        institution: item.institution,
        annee_obtention: String(item.annee_obtention),
        mention: item.mention,
      });
    } else {
      setFormType("professional");
      setForm({
        poste: item.poste,
        entreprise: item.entreprise,
        date_debut: item.date_debut,
        type_contrat: item.type_contrat,
      });
    }
    dialogRef.current?.showModal();
  };

  const handleChange = (
    e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>
  ) => {
    const { name, value } = e.target;
    setForm((prev) => ({ ...prev, [name]: value }));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      if (formType === "academic") {
        const academicForm = form as AcademicForm;
        const payload: Omit<ParcoursAcademique, "id"> = {
          diplome: academicForm.diplome,
          institution: academicForm.institution,
          annee_obtention: parseInt(academicForm.annee_obtention, 10),
          mention: academicForm.mention || null,
        };
        if (editing) {
          await updateParcoursAcademique(
            (editing as ParcoursAcademique).id,
            payload
          );
        } else {
          await createParcoursAcademique(payload);
        }
      } else if (formType === "professional") {
        const professionalForm = form as ProfessionalForm;
        const payload: Omit<ParcoursProfessionnel, "id"> = {
          poste: professionalForm.poste,
          entreprise: professionalForm.entreprise,
          date_debut: professionalForm.date_debut,
          type_contrat: professionalForm.type_contrat,
        };
        if (editing) {
          await updateParcoursProfessionnel(
            (editing as ParcoursProfessionnel).id,
            payload
          );
        } else {
          await createParcoursProfessionnel(payload);
        }
      }
      dialogRef.current?.close();
      onChanged();
    } catch (error) {
      console.error("Failed to save parcours:", error);
    }
  };

  const handleDelete = async (
    id: number,
    type: "academic" | "professional"
  ) => {
    if (window.confirm("Êtes-vous sûr de vouloir supprimer cet élément ?")) {
      try {
        if (type === "academic") {
          await deleteParcoursAcademique(id);
        } else {
          await deleteParcoursProfessionnel(id);
        }
        onChanged();
      } catch (error) {
        console.error("Failed to delete parcours:", error);
      }
    }
  };

  return (
    <div className="bg-base-100 p-6 rounded-2xl shadow-lg">
      <div className="flex justify-between items-center mb-4">
        <h2 className="text-2xl font-bold">Parcours</h2>
        <div className="flex gap-2">
          <button
            className="btn btn-primary btn-sm"
            onClick={() => openCreate("academic")}
          >
            <Plus size={18} className="mr-1" />
            Ajouter Académique
          </button>
          <button
            className="btn btn-primary btn-sm"
            onClick={() => openCreate("professional")}
          >
            <Plus size={18} className="mr-1" />
            Ajouter Professionnel
          </button>
        </div>
      </div>
      <div className="space-y-4">
        <h3 className="text-xl font-bold">Académique</h3>
        {academicItems.length > 0 ? (
          academicItems.map((p) => (
            <ParcoursItem
              key={`ac-${p.id}`}
              item={p}
              onDelete={handleDelete}
              onEdit={openEdit}
            />
          ))
        ) : (
          <p className="text-center text-base-content/60 py-4">
            Aucun parcours académique n&apos;a été ajouté pour le moment.
          </p>
        )}

        <div className="divider"></div>

        <h3 className="text-xl font-bold">Professionnel</h3>
        {professionalItems.length > 0 ? (
          professionalItems.map((p) => (
            <ParcoursItem
              key={`pro-${p.id}`}
              item={p}
              onDelete={handleDelete}
              onEdit={openEdit}
            />
          ))
        ) : (
          <p className="text-center text-base-content/60 py-4">
            Aucun parcours professionnel n&apos;a été ajouté pour le moment.
          </p>
        )}
      </div>

      <dialog ref={dialogRef} className="modal">
        <div className="modal-box">
          <h3 className="font-bold text-lg mb-4">
            {editing ? "Modifier le" : "Ajouter un"} parcours{" "}
            {formType === "academic" ? "académique" : "professionnel"}
          </h3>
          <form onSubmit={handleSubmit} className="space-y-4">
            {formType === "academic" ? (
              <>
                <Input
                  name="diplome"
                  value={(form as AcademicForm).diplome || ""}
                  onChange={handleChange}
                  placeholder="Diplôme"
                  required
                />
                <Input
                  name="institution"
                  value={(form as AcademicForm).institution || ""}
                  onChange={handleChange}
                  placeholder="Institution"
                  required
                />
                <Input
                  name="annee_obtention"
                  type="number"
                  value={(form as AcademicForm).annee_obtention || ""}
                  onChange={handleChange}
                  placeholder="Année d'obtention"
                  required
                />
                <select
                  name="mention"
                  value={(form as AcademicForm).mention || ""}
                  className="select select-bordered w-full"
                  onChange={handleChange}
                >
                  <option value="">Sélectionnez une mention (optionnel)</option>
                  {Object.keys(Mentions).map((key) => (
                    <option
                      key={key.replace("mention_", "")}
                      value={key.replace("mention_", "")}
                    >
                      {Mentions[key as keyof typeof Mentions]}
                    </option>
                  ))}
                </select>
              </>
            ) : (
              <>
                <Input
                  name="poste"
                  value={(form as ProfessionalForm).poste || ""}
                  onChange={handleChange}
                  placeholder="Poste"
                  required
                />
                <Input
                  name="entreprise"
                  value={(form as ProfessionalForm).entreprise || ""}
                  onChange={handleChange}
                  placeholder="Entreprise"
                  required
                />
                <Input
                  name="date_debut"
                  type="date"
                  value={(form as ProfessionalForm).date_debut || ""}
                  onChange={handleChange}
                  placeholder="Date de début"
                  required
                />
                <select
                  name="type_contrat"
                  value={(form as ProfessionalForm).type_contrat || ""}
                  className="select select-bordered w-full"
                  onChange={handleChange}
                >
                  {contrats.map((c) => (
                    <option key={c.value} value={c.value}>
                      {c.label}
                    </option>
                  ))}
                </select>
              </>
            )}
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
