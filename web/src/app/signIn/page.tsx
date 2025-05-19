"use client";

import { useState } from "react";
import "../globals.css";

export default function singIn() {
  const [userType, setUserType] = useState("alumni");
  const [isPasswordEqual, setIsPasswordEqual] = useState(true);
  const [confirmPassword, setConfirmPassword] = useState("");
  const [user, setUser] = useState({
    email: "",
    username: "",
    nom: "",
    prenom: "",
    password: "",
  });
  const [alumniData, setAlumniData] = useState<{
    date_fin_cycle: string;
    secteur_activite: keyof typeof jobBySector;
    situation_pro: string;
    poste_actuel: string;
    nom_entreprise: string;
  }>({
    date_fin_cycle: "",
    secteur_activite: "Autres",
    situation_pro: "",
    poste_actuel: "",
    nom_entreprise: "",
  });
  const [studentData, setStudentData] = useState({
    filiere: "",
    niveau_etude: "",
    annee_entree: "",
    a_besoin_mentor: false,
  });

  const [selectedSector, setSelectedSector] = useState();
  const jobBySector = {
    "Marketing et Ventes": [
      "Chef de produit",
      "Responsable marketing",
      "Commercial terrain",
      "Category manager",
      "Chef des ventes",
    ],
    "Ressources Humaines": [
      "Chargé de recrutement",
      "Gestionnaire de paie",
      "Responsable formation",
      "Chargé des relations sociales",
      "Consultant RH",
    ],
    "Comptabilité Finance": [
      "Comptable général",
      "Contrôleur de gestion",
      "Auditeur financier",
      "Analyste financier",
      "Trésorier d’entreprise",
    ],
    "Marketing Digital": [
      "Community manager",
      "Traffic manager",
      "SEO/SEA manager",
      "Growth hacker",
      "Responsable e-mailing",
    ],
    Communication: [
      "Chargé de communication",
      "Attaché de presse",
      "Directeur de la communication",
      "Concepteur-rédacteur",
      "Event manager",
    ],
    "Logistique et Transport": [
      "Responsable logistique",
      "Planificateur transport",
      "Gestionnaire d’entrepôt",
      "Chef de quai",
      "Coordinateur supply chain",
    ],
    "Informatique, Réseaux et Télécommunications": [
      "Administrateur systèmes et réseaux",
      "Ingénieur télécoms",
      "Développeur logiciel",
      "Ingénieur cybersécurité",
      "Architecte cloud",
    ],
    "Relations Internationales & Diplomatie": [
      "Attaché diplomatique",
      "Chargé de mission internationale",
      "Analyste géopolitique",
      "Coordinateur ONG",
      "Conseiller en relations publiques internationales",
    ],
    Autres: ["Autres"],
  };

  const niveau_etude = [
    "Licence 1",
    "Licence 2",
    "Licence 3",
    "Master 1",
    "Master 2",
  ];

  const handleConfirmPasswordChange = (e: { target: { value: string } }) => {
    setConfirmPassword(e.target.value);
  };

  const handleUserChange = (e: { target: { name: any; value: any } }) => {
    const { name, value } = e.target;
    setUser((prev) => ({ ...prev, [name]: value }));
  };

  const handleAlumniChange = (e: { target: { name: any; value: any } }) => {
    const { name, value } = e.target;
    setAlumniData((prev) => ({ ...prev, [name]: value }));
  };

  const handleStudentChange = (e: { target: { name: any; value: any } }) => {
    const { name, value } = e.target;
    setStudentData((prev) => ({
      ...prev,
      [name]: value,
    }));
  };

  //setInterval(() => console.log(alumniData), 15000);
  //clearInterval(1);
  const situationProOptions = [
    { value: "stubbler", label: "Chaummeur" },
    { value: "intern", label: "stagiaire" },
    { value: "Employee", label: "Employé" },
    { value: "entrepreneur", label: "Entrepreneur" },
  ];
  const handleSubmit = async (e: { preventDefault: () => void }) => {
    e.preventDefault();
    const payload = {
      user,
      ...(userType === "alumni" ? alumniData : studentData),
    };
    if (user.password !== confirmPassword) {
      setIsPasswordEqual(false);
      return;
    }

    try {
      const res = await fetch("/api/register", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(payload),
      });
      if (!res.ok) throw new Error("Registration failed");
      alert("Inscription réussie!");
    } catch (err) {
      console.error(err);
      alert("Une erreur est survenue.");
    }
  };

  return (
    <div className="in-h-screen flex flex-11/12 items-center justify-center">
      <div
        className={`p-8 rounded-2xl shadow-xl w-full
    transition-all duration-500 ease-in-out
    ${userType === "alumni" ? "max-w-lg max-h-max" : "max-w-lg max-h-max"}`}
      >
        <h1 className="text-2xl font-semibold mb-6 text-center">Inscription</h1>
        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="form-control">
            <label className="label cursor-pointer flex items-center space-x-3">
              <span className="label-text">Étudiant</span>
              <input
                type="checkbox"
                className="toggle border-indigo-600 bg-indigo-500 checked:border-purple-500 checked:bg-purple-400 checked:text-purple-800"
                checked={userType === "alumni"}
                onChange={() =>
                  setUserType((prev) =>
                    prev === "alumni" ? "student" : "alumni"
                  )
                }
              />
              <span className="label-text mb-1">Alumni</span>
            </label>
          </div>

          <fieldset className="space-y-4">
            <div className="grid grid-cols-2 gap-4">
              <div>
                <label className="block mb-1">Nom</label>
                <input
                  type="text"
                  name="nom"
                  value={user.nom}
                  onChange={handleUserChange}
                  required
                  className="input input-primary"
                />
              </div>
              <div>
                <label className="block mb-1">Prénom</label>
                <input
                  type="text"
                  name="prenom"
                  value={user.prenom}
                  onChange={handleUserChange}
                  required
                  className="input input-primary"
                />
              </div>
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div>
                <label className="block mb-1">Email</label>
                <input
                  type="email"
                  name="email"
                  value={user.email}
                  onChange={handleUserChange}
                  required
                  data-label="Email"
                  className="input input-primary"
                />
              </div>
              <div>
                <label className="block mb-1">Nom d'utilisateur</label>
                <input
                  type="text"
                  name="username"
                  value={user.username}
                  onChange={handleUserChange}
                  required
                  className="input input-primary"
                  data-label="Nom d'utilisateur"
                />
              </div>
            </div>

            <div className="grid grid-cols-2 gap-4">
              <div>
                <label className="block mb-1">Mot de passe</label>

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
                <label className="block mb-1">Confirmer le mot de passe</label>
                <input
                  type="password"
                  name="password"
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

          {userType === "alumni" ? (
            <fieldset className="space-y-4">
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block mb-1">Date de fin de cycle</label>
                  <input
                    type="date"
                    name="date_fin_cycle"
                    value={alumniData.date_fin_cycle}
                    onChange={handleAlumniChange}
                    required
                    className="input input-primary"
                  />
                </div>
                <div>
                  <label className="block mb-1">Secteur d'activité</label>
                  <select
                    className="select select-primary"
                    onChange={handleAlumniChange}
                    name="secteur_activite"
                  >
                    {Object.keys(jobBySector).map((item: string) => (
                      <option value={item} key={item}>
                        {item}
                      </option>
                    ))}
                  </select>
                </div>
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block mb-1 content-center">
                    Situation professionnelle
                  </label>
                  <select
                    defaultValue="Chaumage"
                    className="select select-primary"
                    onChange={handleAlumniChange}
                    name="situation_pro"
                  >
                    <option disabled={false}>Chaumage</option>
                    <option value={"stage"}>Stage</option>
                    <option value={"employee"}>Employé</option>
                    <option value={"Entrepreneur"}>Entrepreneur</option>
                  </select>
                </div>
                <div>
                  <label className="block mb-1">Poste actuel</label>
                  <select
                    className="select select-primary"
                    onChange={handleAlumniChange}
                    name="poste_actuel"
                  >
                    {jobBySector[alumniData.secteur_activite].map(
                      (item: string) => (
                        <option
                          defaultValue={jobBySector["Marketing Digital"]}
                          value={item}
                          key={item}
                        >
                          {item}
                        </option>
                      )
                    )}
                  </select>
                </div>
              </div>
              <div>
                <label className="block mb-1">Nom de l'entreprise</label>
                <input
                  type="text"
                  name="nom_entreprise"
                  value={alumniData.nom_entreprise}
                  onChange={handleAlumniChange}
                  className="input input-primary"
                />
              </div>
            </fieldset>
          ) : (
            <fieldset className="space-y-4">
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block mb-1">Filière</label>
                  <select
                    name="filiere"
                    value={studentData.filiere}
                    onChange={handleStudentChange}
                    required
                    className="select select-primary"
                  >
                    {Object.keys(jobBySector).map((item: string) => (
                      <option value={item} key={item}>
                        {item}
                      </option>
                    ))}
                  </select>
                </div>
                <div>
                  <label className="block mb-1">Niveau d'étude</label>
                  <select
                    name="niveau_etude"
                    value={studentData.niveau_etude}
                    onChange={handleStudentChange}
                    className="select select-primary"
                  >
                    {niveau_etude.map((item: string) => (
                      <option value={item} key={item}>
                        {item}
                      </option>
                    ))}
                  </select>
                </div>
              </div>
              <div>
                <label className="block mb-1">Année d'entrée</label>
                <input
                  type="date"
                  name="annee_entree"
                  min="2016-01-01"
                  value={studentData.annee_entree}
                  onChange={handleStudentChange}
                  className="select select-primary"
                />
              </div>
            </fieldset>
          )}

          <button type="submit" className="w-full btn btn-primary">
            S'inscrire
          </button>
        </form>
        <div className="mt-4 text-sm text-center text-gray-500">
          Vous avez déjà un compte ?{" "}
          <a href="/login" className="text-blue-600 hover:underline">
            Connectez-vous
          </a>
        </div>
      </div>
    </div>
  );
}
