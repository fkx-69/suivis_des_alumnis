"use client";
import React from "react";
import { useFormContext, useWatch } from "react-hook-form";
import type { Filiere } from "@/lib/api/filiere";
import { type AlumniFormValues } from "@/lib/validators/auth";
import { Input } from "@/components/ui/Input";
import { jobBySector } from "@/lib/constants";

interface AlumniFormProps {
  filieres: Filiere[];
  error?: string;
}

export default function AlumniForm({ filieres, error }: AlumniFormProps) {
  const {
    register,
    formState: { errors },
    control,
  } = useFormContext<AlumniFormValues>();
  const situationPro = useWatch({
    control,
    name: "situation_pro",
  });

  const years = Array.from(
    { length: new Date().getFullYear() - 2017 + 1 },
    (_, i) => 2017 + i,
  );

  const secteurActivite = useWatch({
    control,
    name: "secteur_activite",
  });

  const isJobSeeking = situationPro === "chomage";

  return (
    <fieldset className="space-y-4">
      <div className="grid grid-cols-2 gap-4">
        <div>
          <label className="block mb-1 text-base-content">Filière</label>
          <select
            className="select select-primary w-full"
            {...register("filiere")}
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
            Situation professionnelle
          </label>
          <select
            {...register("situation_pro")}
            className="select select-primary w-full"
          >
            <option value="chomage">En recherche d&apos;emploi</option>
            <option value="stage">En stage</option>
            <option value="emploi">En emploi</option>
            <option value="formation">En formation</option>
            <option value="autre">Autre</option>
          </select>
          {errors.situation_pro && (
            <p className="text-error text-xs mt-1">
              {errors.situation_pro.message}
            </p>
          )}
        </div>
      </div>

      <div className="grid grid-cols-2 gap-4">
        <div>
          <label className="block mb-1 text-base-content">
            Secteur d&apos;activité
          </label>
          <select
            className="select select-primary w-full"
            {...register("secteur_activite")}
            disabled={isJobSeeking}
          >
            {Object.keys(jobBySector).map((key) => (
              <option key={key} value={key}>
                {key}
              </option>
            ))}
          </select>
        </div>
        <div>
          <label className="block mb-1 text-base-content">Poste actuel</label>
          <select
            className="select select-primary w-full"
            {...register("poste_actuel")}
            disabled={isJobSeeking}
          >
            {Object.entries(
              jobBySector[secteurActivite as keyof typeof jobBySector] || {},
            ).map(([key, value]) => (
              <option key={key} value={key}>
                {value}
              </option>
            ))}
          </select>
        </div>
      </div>

      <Input
        label="Nom de l'entreprise"
        {...register("nom_entreprise")}
        className="input input-primary"
        disabled={isJobSeeking}
      />
      <label className="block mb-1 text-base-content">
        Année de fin de cycle
      </label>
      <select className="select select-primary" {...register("date_fin_cycle")}>
        {years.map((year) => (
          <option key={year} value={String(year)}>
            {year}
          </option>
        ))}
      </select>
      {error && <p className="text-error text-sm mt-1">{error}</p>}
    </fieldset>
  );
}
