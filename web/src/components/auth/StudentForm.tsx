"use client";
import React from "react";
import { useFormContext } from "react-hook-form";
import type { Filiere } from "@/lib/api/filiere";
import { type StudentFormValues } from "@/lib/validators/auth";
import { niveau_etude } from "@/lib/constants";

interface StudentFormProps {
  filieres: Filiere[];
  error?: string;
}

export default function StudentForm({ filieres, error }: StudentFormProps) {
  const {
    register,
    formState: { errors },
  } = useFormContext<StudentFormValues>();
  const years = Array.from(
    { length: new Date().getFullYear() - 2017 + 1 },
    (_, i) => 2017 + i,
  );
  return (
    <fieldset className="space-y-4">
      <div className="grid grid-cols-2 gap-4">
        <div>
          <label className="block mb-1 text-base-content">Filière</label>
          <select
            {...register("filiere")}
            required
            className="select select-primary w-full"
          >
            {filieres.map((filiere) => (
              <option key={filiere.id} value={filiere.id}>
                {filiere.nom_complet}
              </option>
            ))}
          </select>
          {errors.filiere && (
            <p className="text-error text-xs mt-1">{errors.filiere.message}</p>
          )}
        </div>
        <div>
          <label className="block mb-1 text-base-content">
            Niveau d&apos;étude
          </label>
          <select
            {...register("niveau_etude")}
            className="select select-primary w-full"
          >
            {niveau_etude.map((niv) => (
              <option key={niv} value={niv}>
                {niv}
              </option>
            ))}
          </select>
          {errors["niveau_etude"] && (
            <p className="text-error text-xs mt-1">
              {errors["niveau_etude"].message}
            </p>
          )}
        </div>
      </div>
      <div>
        <label className="block mb-1 text-base-content">
          Année d&apos;entrée
        </label>
        <select
          className="select select-primary w-full"
          {...register("annee_entree")}
        >
          {years.map((year) => (
            <option key={year} value={String(year)}>
              {year}
            </option>
          ))}
        </select>
        {errors["annee_entree"] && (
          <p className="text-error text-xs mt-1">
            {errors["annee_entree"].message}
          </p>
        )}
      </div>
      {error && <p className="text-error text-sm mt-1">{error}</p>}
    </fieldset>
  );
}
