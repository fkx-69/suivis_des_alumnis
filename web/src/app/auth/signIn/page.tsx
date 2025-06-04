"use client";

import { useState } from "react";
import { registerAlumni, registerStudent } from "@/lib/api/auth";
import axios from "axios";
import { arrayOutputType, object } from "zod";

export default function SignIn() {
  // États de base
  const [userType, setUserType] = useState<"student" | "alumni">("alumni");
  const [isPasswordEqual, setIsPasswordEqual] = useState(true);
  const [confirmPassword, setConfirmPassword] = useState("");

  const currentYear = new Date().getFullYear();
  const years = [];
  const [messageError, setMessageError] = useState<MessageError>({});
  type MessageError = {
    [key: string]: Array<string>;
  };
  for (let year = 2017; year <= currentYear; year++) {
    years.push(year);
  }
  const [isJobSeeking, setIsJobSeeking] = useState(true);

  const [user, setUser] = useState({
    email: "",
    username: "",
    nom: "",
    prenom: "",
    password: "",
  });

  /**
   * Dictionnaire des secteurs (clés ≤ 10 caractères comme exigé côté back‑end)
   */
  const jobBySector = {
    marketinge: [
      "Chef de produit",
      "Responsable marketing",
      "Commercial terrain",
      "Category manager",
      "Chef des ventes",
    ],
    ressources: [
      "Chargé de recrutement",
      "Gestionnaire de paie",
      "Responsable formation",
      "Chargé des relations sociales",
      "Consultant RH",
    ],
    comptabili: [
      "Comptable général",
      "Contrôleur de gestion",
      "Auditeur financier",
      "Analyste financier",
      "Trésorier d'entreprise",
    ],
    marketingd: [
      "Community manager",
      "Traffic manager",
      "SEO/SEA manager",
      "Growth hacker",
      "Responsable e-mailing",
    ],
    communicat: [
      "Chargé de communication",
      "Attaché de presse",
      "Directeur de la communication",
      "Concepteur‑rédacteur",
      "Event manager",
    ],
    logistique: [
      "Responsable logistique",
      "Planificateur transport",
      "Gestionnaire d'entrepôt",
      "Chef de quai",
      "Coordinateur supply chain",
    ],
    informatiq: [
      "Administrateur systèmes et réseaux",
      "Ingénieur télécoms",
      "Développeur logiciel",
      "Ingénieur cybersécurité",
      "Architecte cloud",
    ],
    relationsi: [
      "Attaché diplomatique",
      "Chargé de mission internationale",
      "Analyste géopolitique",
      "Coordinateur ONG",
      "Conseiller RP internationales",
    ],
    autres: ["Autres"],
  } as const;
  type SectorKey = keyof typeof jobBySector;

  /**
   * Données spécifiques alumni / étudiants
   */
  const [alumniData, setAlumniData] = useState<{
    date_fin_cycle: string;
    secteur_activite: SectorKey;
    situation_pro: string;
    poste_actuel: string;
    nom_entreprise: string;
    filiere: SectorKey;
    role: string;
  }>({
    date_fin_cycle: "",
    secteur_activite: "autres",
    situation_pro: "",
    poste_actuel: "",
    nom_entreprise: "",
    filiere: "autres",
    role: "alumni",
  });

  const [studentData, setStudentData] = useState({
    filiere: "",
    niveau_etude: "",
    annee_entree: 2019,
    role: "etudiant",
  });

  /**
   * Listes fixes
   */
  const niveau_etude = ["L1", "L2", "L3", "M1", "M2"];

  /** Handlers */
  const handleConfirmPasswordChange = (
    e: React.ChangeEvent<HTMLInputElement>
  ) => setConfirmPassword(e.target.value);

  const handleUserChange = (e: React.ChangeEvent<HTMLInputElement>) =>
    setUser((prev) => ({ ...prev, [e.target.name]: e.target.value }));

  const handleAlumniChange = (
    e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>
  ) => setAlumniData((prev) => ({ ...prev, [e.target.name]: e.target.value }));

  // Combinaison : met à jour alumniData + l'état « en recherche d'emploi »
  const handleSituationChange = (e: React.ChangeEvent<HTMLSelectElement>) => {
    handleAlumniChange(e);
    setIsJobSeeking(e.target.value === "En recherche d'emploi");
  };

  const handleStudentChange = (
    e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>
  ) => setStudentData((prev) => ({ ...prev, [e.target.name]: e.target.value }));

  /** Soumission du formulaire */
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    // 1. Vérification mot de passe
    if (user.password !== confirmPassword) {
      setIsPasswordEqual(false);
      return;
    }

    // 2. Construction du payload
    const payload = {
      user,
      ...(userType === "alumni" ? alumniData : studentData),
    };

    try {
      console.log("Payload envoyé :", payload);

      // 3. Appel API : on attend la réponse UNE fois
      const res =
        userType === "alumni"
          ? await registerAlumni(payload)
          : await registerStudent(payload);

      // 4. Succès (2xx)
      console.log("Réponse succès :", res.data);
      alert("Inscription réussie !");
    } catch (err) {
      if (axios.isAxiosError(err) && err.response) {
        const { status, data } = err.response;

        if (status === 400) {
          // 1. On récupère soit data.user, soit tout data
          const errors = (data.user as MessageError) ?? (data as MessageError);

          // 2. On reconstruit un objet d’erreurs
          const newMessageError: MessageError = {};
          Object.keys(errors).forEach((field) => {
            newMessageError[field] = errors[field];
            if (messageError[field] && !errors[field]) {
              // Si le champ n'a plus d'erreurs, on le retire du state
              delete messageError[field];
            }
          });

          // 3. On met à jour le state pour déclencher le rendu
          setMessageError(newMessageError);

          // on sort avant l’alert générique
          return;
        }
      }

      console.error(err);
      alert("Une erreur est survenue.");
    }
  };

  return (
    <div className="min-h-screen flex w-full items-center justify-center bg-base-200">
      <div
        className={`p-8 rounded-2xl shadow-xl w-full bg-base-100 transition-all duration-500 ease-in-out max-w-max max-h-max`}
      >
        <h1 className="text-2xl font-semibold mb-6 text-center text-base-content">
          Inscription
        </h1>

        <form onSubmit={handleSubmit} className="space-y-4">
          {/* Type d'utilisateur */}
          <div className="form-control">
            <label className="block mb-1 text-base-content">
              Type d'utilisateur
            </label>
            <select
              className="select select-primary w-full max-w-xs"
              value={userType}
              onChange={(e) =>
                setUserType(e.target.value as "student" | "alumni")
              }
            >
              <option value="student">Étudiant</option>
              <option value="alumni">Alumni</option>
            </select>
          </div>

          {/* Bloc infos personnelles */}
          <fieldset className="space-y-4">
            <div className="grid grid-cols-2 gap-4">
              <div>
                <label className="block mb-1 text-base-content">Nom</label>
                <input
                  type="text"
                  name="nom"
                  value={user.nom}
                  onChange={handleUserChange}
                  required
                  className="input input-primary"
                />
                {messageError.nom &&
                  messageError.nom.map((msg) => (
                    <p className="text-error">{msg}</p>
                  ))}
              </div>
              <div>
                <label className="block mb-1 text-base-content">Prénom</label>
                <input
                  type="text"
                  name="prenom"
                  value={user.prenom}
                  onChange={handleUserChange}
                  required
                  className="input input-primary"
                />
                {messageError.prenom &&
                  messageError.prenom.map((msg) => (
                    <p className="text-error">{msg}</p>
                  ))}
              </div>
            </div>

            <div className="grid grid-cols-2 gap-4">
              <div>
                <label className="block mb-1 text-base-content">Email</label>
                <input
                  type="email"
                  name="email"
                  value={user.email}
                  onChange={handleUserChange}
                  required
                  className="input input-primary"
                />
                {messageError.email &&
                  messageError.email.map((msg) => (
                    <p className="text-error">{msg}</p>
                  ))}
              </div>
              <div>
                <label className="block mb-1 text-base-content">
                  Nom d'utilisateur
                </label>
                <input
                  type="text"
                  name="username"
                  value={user.username}
                  onChange={handleUserChange}
                  required
                  className="input input-primary"
                />
                {messageError.username &&
                  messageError.username.map((msg) => (
                    <p className="text-error">{msg}</p>
                  ))}
              </div>
            </div>

            <div className="grid grid-cols-2 gap-4">
              <div>
                <label className="block mb-1 text-base-content">
                  Mot de passe
                </label>
                <input
                  type="password"
                  name="password"
                  value={user.password}
                  onChange={handleUserChange}
                  required
                  className={`input ${
                    isPasswordEqual ? "input-primary" : "input-error"
                  }`}
                />
              </div>
              <div>
                <label className="block mb-1 text-base-content">
                  Confirmer le mot de passe
                </label>
                <input
                  type="password"
                  name="confirmPassword"
                  onChange={handleConfirmPasswordChange}
                  required
                  className={`input ${
                    isPasswordEqual ? "input-primary" : "input-error"
                  }`}
                />
              </div>
            </div>
            {!isPasswordEqual && (
              <p className="text-red-500 text-sm">
                Les mots de passe ne correspondent pas.
              </p>
            )}
          </fieldset>

          {/* Bloc spécifique ALUMNI */}
          {userType === "alumni" ? (
            <fieldset className="space-y-4">
              {/* Filière + Situation */}
              <div className="grid grid-cols-2 gap-4">
                {/* Sélection du secteur (label « Filière » dans la maquette) – TOUJOURS actif */}
                <div>
                  <label className="block mb-1 text-base-content">
                    Filière
                  </label>
                  <select
                    className="select select-primary"
                    name="secteur_activite"
                    value={alumniData.secteur_activite}
                    onChange={handleAlumniChange}
                  >
                    {Object.keys(jobBySector).map((key) => (
                      <option key={key} value={key}>
                        {key}
                      </option>
                    ))}
                  </select>
                </div>

                {/* Situation pro – met à jour isJobSeeking */}
                <div>
                  <label className="block mb-1 text-base-content">
                    Situation professionnelle
                  </label>
                  <select
                    name="situation_pro"
                    className="select select-primary"
                    value={alumniData.situation_pro}
                    onChange={handleSituationChange}
                  >
                    <option value="En recherche d'emploi">
                      En recherche d'emploi
                    </option>
                    <option value="stage">En stage</option>
                    <option value="employee">En emploi</option>
                    <option value="Entrepreneur">En formation</option>
                    <option value="autre">Autre</option>
                  </select>
                </div>
              </div>

              {/* Secteur + Poste – désactivés si isJobSeeking */}
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block mb-1 text-base-content">
                    Secteur d'activité
                  </label>
                  <select
                    className="select select-primary"
                    name="secteur_activite"
                    value={alumniData.secteur_activite}
                    onChange={handleAlumniChange}
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
                  <label className="block mb-1 text-base-content">
                    Poste actuel
                  </label>
                  <select
                    className="select select-primary"
                    name="poste_actuel"
                    value={alumniData.poste_actuel}
                    onChange={handleAlumniChange}
                    disabled={isJobSeeking}
                  >
                    {(jobBySector[alumniData.secteur_activite] ?? []).map(
                      (poste) => (
                        <option key={poste} value={poste}>
                          {poste}
                        </option>
                      )
                    )}
                  </select>
                </div>
              </div>

              {/* Nom entreprise – désactivé si isJobSeeking */}
              <div>
                <label className="block mb-1 text-base-content">
                  Nom de l'entreprise
                </label>
                <input
                  type="text"
                  name="nom_entreprise"
                  value={alumniData.nom_entreprise}
                  onChange={handleAlumniChange}
                  className="input input-primary"
                  disabled={isJobSeeking}
                />
              </div>
            </fieldset>
          ) : (
            /* Bloc spécifique ÉTUDIANT */
            <fieldset className="space-y-4">
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block mb-1 text-base-content">
                    Filière
                  </label>
                  <select
                    name="filiere"
                    value={studentData.filiere}
                    onChange={handleStudentChange}
                    required
                    className="select select-primary"
                  >
                    {Object.keys(jobBySector).map((key) => (
                      <option key={key} value={key}>
                        {key}
                      </option>
                    ))}
                  </select>
                </div>
                <div>
                  <label className="block mb-1 text-base-content">
                    Niveau d'étude
                  </label>
                  <select
                    name="niveau_etude"
                    value={studentData.niveau_etude}
                    onChange={handleStudentChange}
                    className="select select-primary"
                  >
                    {niveau_etude.map((niv) => (
                      <option key={niv} value={niv}>
                        {niv}
                      </option>
                    ))}
                  </select>
                </div>
              </div>
              <div>
                <label className="block mb-1 text-base-content">
                  Année d'entrée
                </label>
                <select
                  className="select select-primary"
                  onChange={handleStudentChange}
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
          )}

          <button type="submit" className="w-full btn btn-primary">
            S'inscrire
          </button>
        </form>

        <div className="mt-4 text-sm text-center text-gray-500">
          Vous avez déjà un compte ?{" "}
          <a href="/auth/login" className="text-blue-600 hover:underline">
            Connectez-vous
          </a>
        </div>
      </div>
    </div>
  );
}
