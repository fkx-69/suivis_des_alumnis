'use client';
import React from 'react';
import type { Filiere } from '@/lib/api/filiere';
import type { AlumniRegisterPayload } from '@/types/auth';

export interface AlumniFormProps {
  filieres: Filiere[];
  alumniData: Omit<AlumniRegisterPayload, 'user'>;
  isJobSeeking: boolean;
  jobBySector: Record<string, string[]>;
  onAlumniChange: (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => void;
  onSituationChange: (e: React.ChangeEvent<HTMLSelectElement>) => void;
}

export default function AlumniForm({
  filieres,
  alumniData,
  isJobSeeking,
  jobBySector,
  onAlumniChange,
  onSituationChange,
}: AlumniFormProps) {
  return (
    <fieldset className="space-y-4">
      <div className="grid grid-cols-2 gap-4">
        <div>
          <label className="block mb-1 text-base-content">Filière</label>
          <select
            className="select select-primary"
            name="filiere"
            value={alumniData.filiere}
            onChange={onAlumniChange}
          >
            {filieres.map((filiere) => (
              <option key={filiere.code} value={filiere.code}>
                {filiere.nom_complet}
              </option>
            ))}
          </select>
        </div>
        <div>
          <label className="block mb-1 text-base-content">Situation professionnelle</label>
          <select
            name="situation_pro"
            className="select select-primary"
            value={alumniData.situation_pro}
            onChange={onSituationChange}
          >
            <option value="chomage">En recherche d'emploi</option>
            <option value="stage">En stage</option>
            <option value="emploi">En emploi</option>
            <option value="formation">En formation</option>
            <option value="autre">Autre</option>
          </select>
        </div>
      </div>

      <div className="grid grid-cols-2 gap-4">
        <div>
          <label className="block mb-1 text-base-content">Secteur d'activité</label>
          <select
            className="select select-primary"
            name="secteur_activite"
            value={alumniData.secteur_activite}
            onChange={onAlumniChange}
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
            className="select select-primary"
            name="poste_actuel"
            value={alumniData.poste_actuel}
            onChange={onAlumniChange}
            disabled={isJobSeeking}
          >
            {(jobBySector[alumniData.secteur_activite as keyof typeof jobBySector] || []).map((poste) => (
              <option key={poste} value={poste}>
                {poste}
              </option>
            ))}
          </select>
        </div>
      </div>

      <div>
        <label className="block mb-1 text-base-content">Nom de l'entreprise</label>
        <input
          type="text"
          name="nom_entreprise"
          value={alumniData.nom_entreprise}
          onChange={onAlumniChange}
          className="input input-primary"
          disabled={isJobSeeking}
        />
      </div>
    </fieldset>
  );
}
