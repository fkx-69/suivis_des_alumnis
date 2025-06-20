'use client';
import React from 'react';
import type { Filiere } from '@/lib/api/filiere';
import type { StudentRegisterPayload } from '@/types/auth';

export interface StudentFormProps {
  filieres: Filiere[];
  studentData: Omit<StudentRegisterPayload, 'user'>;
  years: number[];
  niveaux: string[];
  onStudentChange: (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => void;
}

export default function StudentForm({
  filieres,
  studentData,
  years,
  niveaux,
  onStudentChange,
}: StudentFormProps) {
  return (
    <fieldset className="space-y-4">
      <div className="grid grid-cols-2 gap-4">
        <div>
          <label className="block mb-1 text-base-content">Filière</label>
          <select
            name="filiere"
            value={studentData.filiere}
            onChange={onStudentChange}
            required
            className="select select-primary"
          >
            {filieres.map((filiere) => (
              <option key={filiere.code} value={filiere.code}>
                {filiere.nom_complet}
              </option>
            ))}
          </select>
        </div>
        <div>
          <label className="block mb-1 text-base-content">Niveau d'étude</label>
          <select
            name="niveau_etude"
            value={studentData.niveau_etude}
            onChange={onStudentChange}
            className="select select-primary"
          >
            {niveaux.map((niv) => (
              <option key={niv} value={niv}>
                {niv}
              </option>
            ))}
          </select>
        </div>
      </div>
      <div>
        <label className="block mb-1 text-base-content">Année d'entrée</label>
        <select
          className="select select-primary"
          onChange={onStudentChange}
          name="annee_entree"
          value={studentData.annee_entree}
        >
          {years.map((year) => (
            <option key={year} value={year}>
              {year}
            </option>
          ))}
        </select>
      </div>
    </fieldset>
  );
}
