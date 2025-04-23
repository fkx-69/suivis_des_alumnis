"use client";

import { useState } from "react";

export default function singIn() {
  const [userType, setUserType] = useState("alumni");
  const [user, setUser] = useState({
    email: "",
    username: "",
    nom: "",
    prenom: "",
    password: "",
  });
  const [alumniData, setAlumniData] = useState({
    date_fin_cycle: "",
    secteur_activite: "",
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

  const handleUserChange = (e: { target: { name: any; value: any } }) => {
    const { name, value } = e.target;
    setUser((prev) => ({ ...prev, [name]: value }));
  };

  const handleAlumniChange = (e: { target: { name: any; value: any } }) => {
    const { name, value } = e.target;
    setAlumniData((prev) => ({ ...prev, [name]: value }));
  };

  const handleStudentChange = (e: {
    target: { name: any; value: any; type: any; checked: any };
  }) => {
    const { name, value, type, checked } = e.target;
    setStudentData((prev) => ({
      ...prev,
      [name]: type === "checkbox" ? checked : value,
    }));
  };

  const handleSubmit = async (e: { preventDefault: () => void }) => {
    e.preventDefault();
    const payload = {
      user,
      ...(userType === "alumni" ? alumniData : studentData),
    };

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
    <div className="max-w-md mx-auto p-6 bg-white rounded-lg shadow-md">
      <h1 className="text-2xl font-semibold mb-6 text-center">Inscription</h1>
      <form onSubmit={handleSubmit} className="space-y-4">
        <div>
          <label className="block mb-2 font-medium">Type d'utilisateur :</label>
          <select
            value={userType}
            onChange={(e) => setUserType(e.target.value)}
            className="w-full border border-gray-300 p-2 rounded"
          >
            <option value="alumni">Alumni</option>
            <option value="student">Étudiant</option>
          </select>
        </div>

        <fieldset className="space-y-4">
          <legend className="text-lg font-medium">
            Informations utilisateur
          </legend>
          <div>
            <label className="block mb-1">Email</label>
            <input
              type="email"
              name="email"
              value={user.email}
              onChange={handleUserChange}
              required
              className="w-full border border-gray-300 p-2 rounded"
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
              className="w-full border border-gray-300 p-2 rounded"
            />
          </div>
          <div>
            <label className="block mb-1">Nom</label>
            <input
              type="text"
              name="nom"
              value={user.nom}
              onChange={handleUserChange}
              required
              className="w-full border border-gray-300 p-2 rounded"
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
              className="w-full border border-gray-300 p-2 rounded"
            />
          </div>
          <div>
            <label className="block mb-1">Mot de passe</label>
            <input
              type="password"
              name="password"
              value={user.password}
              onChange={handleUserChange}
              required
              className="w-full border border-gray-300 p-2 rounded"
            />
          </div>
        </fieldset>

        {userType === "alumni" ? (
          <fieldset className="space-y-4">
            <legend className="text-lg font-medium">Informations Alumni</legend>
            <div>
              <label className="block mb-1">Date de fin de cycle</label>
              <input
                type="date"
                name="date_fin_cycle"
                value={alumniData.date_fin_cycle}
                onChange={handleAlumniChange}
                required
                className="w-full border border-gray-300 p-2 rounded"
              />
            </div>
            <div>
              <label className="block mb-1">Secteur d'activité</label>
              <input
                type="text"
                name="secteur_activite"
                value={alumniData.secteur_activite}
                onChange={handleAlumniChange}
                className="w-full border border-gray-300 p-2 rounded"
              />
            </div>
            <div>
              <label className="block mb-1">Situation professionnelle</label>
              <input
                type="text"
                name="situation_pro"
                value={alumniData.situation_pro}
                onChange={handleAlumniChange}
                className="w-full border border-gray-300 p-2 rounded"
              />
            </div>
            <div>
              <label className="block mb-1">Poste actuel</label>
              <input
                type="text"
                name="poste_actuel"
                value={alumniData.poste_actuel}
                onChange={handleAlumniChange}
                className="w-full border border-gray-300 p-2 rounded"
              />
            </div>
            <div>
              <label className="block mb-1">Nom de l'entreprise</label>
              <input
                type="text"
                name="nom_entreprise"
                value={alumniData.nom_entreprise}
                onChange={handleAlumniChange}
                className="w-full border border-gray-300 p-2 rounded"
              />
            </div>
          </fieldset>
        ) : (
          <fieldset className="space-y-4">
            <legend className="text-lg font-medium">
              Informations Étudiant
            </legend>
            <div>
              <label className="block mb-1">Filière</label>
              <input
                type="text"
                name="filiere"
                value={studentData.filiere}
                onChange={handleStudentChange}
                required
                className="w-full border border-gray-300 p-2 rounded"
              />
            </div>
            <div>
              <label className="block mb-1">Niveau d'étude</label>
              <input
                type="text"
                name="niveau_etude"
                value={studentData.niveau_etude}
                onChange={handleStudentChange}
                className="w-full border border-gray-300 p-2 rounded"
              />
            </div>
            <div>
              <label className="block mb-1">Année d'entrée</label>
              <input
                type="number"
                name="annee_entree"
                value={studentData.annee_entree}
                onChange={handleStudentChange}
                className="w-full border border-gray-300 p-2 rounded"
              />
            </div>
            <div className="flex items-center">
              <input
                type="checkbox"
                name="a_besoin_mentor"
                checked={studentData.a_besoin_mentor}
                onChange={handleStudentChange}
                className="h-4 w-4 text-blue-600"
              />
              <label className="ml-2">A besoin d'un mentor</label>
            </div>
          </fieldset>
        )}

        <button
          type="submit"
          className="w-full bg-blue-600 hover:bg-blue-700 text-white font-medium py-2 rounded"
        >
          S'inscrire
        </button>
      </form>
    </div>
  );
}
