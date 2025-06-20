"use client";

import { useState, useEffect } from "react";
import {
  registerAlumni,
  registerStudent,
  login as loginApi,
} from "@/lib/api/auth";
import { useAuth } from "@/lib/api/authContext";
import { fetchFilieres, Filiere } from "@/lib/api/filiere";
import type {
  AlumniRegisterPayload,
  StudentRegisterPayload,
  UserForm,
} from "@/types/auth";
import { useRouter } from "next/navigation";
import axios from "axios";
import PersonalInfoForm, { MessageError } from "@/components/auth/PersonalInfoForm";
import AlumniForm from "@/components/auth/AlumniForm";
import StudentForm from "@/components/auth/StudentForm";

export default function SignIn() {
  const { login } = useAuth();
  const router = useRouter();
  // États de base
  const [userType, setUserType] = useState<"student" | "alumni">("alumni");
  const [isPasswordEqual, setIsPasswordEqual] = useState(true);
  const [confirmPassword, setConfirmPassword] = useState("");
  const [step, setStep] = useState(1);

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

  const [filieres, setFilieres] = useState<Filiere[]>([]);

  useEffect(() => {
    fetchFilieres()
      .then((data) => {
        setFilieres(data);
        if (data.length > 0) {
          setAlumniData((prev) => ({ ...prev, filiere: data[0].code }));
          setStudentData((prev) => ({ ...prev, filiere: data[0].code }));
        }
      })
      .catch((err) => console.error(err));
  }, []);

  const [user, setUser] = useState<UserForm>({
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
  const [alumniData, setAlumniData] = useState<
    Omit<AlumniRegisterPayload, "user">
  >({
    date_fin_cycle: "",
    secteur_activite: "autres",
    situation_pro: "",
    poste_actuel: "",
    nom_entreprise: "",
    filiere: "",
    role: "alumni",
  });

  const [studentData, setStudentData] = useState<
    Omit<StudentRegisterPayload, "user">
  >({
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
  ) =>
    setAlumniData((prev) => ({
      ...prev,
      [e.target.name]: e.target.value,
    }));

  // Combinaison : met à jour alumniData + l'état « en recherche d'emploi »
  const handleSituationChange = (e: React.ChangeEvent<HTMLSelectElement>) => {
    handleAlumniChange(e);
    setIsJobSeeking(e.target.value === "En recherche d'emploi");
  };

  const handleStudentChange = (
    e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>
  ) =>
    setStudentData((prev) => ({
      ...prev,
      [e.target.name]: e.target.value,
    }));

  /** Soumission du formulaire */
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    // 1. Vérification mot de passe
    if (user.password !== confirmPassword) {
      setIsPasswordEqual(false);
      return;
    }

    try {
      let res;

      if (userType === "alumni") {
        const payload: AlumniRegisterPayload = { user, ...alumniData };
        console.log("Payload envoyé :", payload);
        res = await registerAlumni(payload);
      } else {
        const payload: StudentRegisterPayload = { user, ...studentData };
        console.log("Payload envoyé :", payload);
        res = await registerStudent(payload);
      }

      // 4. Succès (2xx)
      console.log("Réponse succès :", res.data);
      const loginRes = await loginApi({
        email: user.email,
        password: user.password,
      });
      localStorage.setItem("token", loginRes.access);
      login(loginRes.user);
      router.push("/");
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
    <div className="min-h-dvh flex w-full items-center justify-center bg-base-200 mx-auto max-w-7xl px-4">
      <div
        className={`p-8 rounded-2xl shadow-xl w-full bg-base-100 transition-all duration-500 ease-in-out max-w-max max-h-max`}
      >
        <h1 className="text-2xl font-semibold mb-6 text-center text-base-content">
          Inscription
        </h1>

        <form onSubmit={handleSubmit} className="space-y-4">
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

          {step === 1 && (
            <PersonalInfoForm
              user={user}
              confirmPassword={confirmPassword}
              isPasswordEqual={isPasswordEqual}
              messageError={messageError}
              onUserChange={handleUserChange}
              onConfirmPasswordChange={handleConfirmPasswordChange}
            />
          )}

          {step === 2 && (
            userType === "alumni" ? (
              <AlumniForm
                filieres={filieres}
                alumniData={alumniData}
                isJobSeeking={isJobSeeking}
                jobBySector={jobBySector}
                onAlumniChange={handleAlumniChange}
                onSituationChange={handleSituationChange}
              />
            ) : (
              <StudentForm
                filieres={filieres}
                studentData={studentData}
                years={years}
                niveaux={niveau_etude}
                onStudentChange={handleStudentChange}
              />
            )
          )}

          {step === 1 ? (
            <button
              type="button"
              onClick={() => setStep(2)}
              className="w-full btn btn-primary"
            >
              Suivant
            </button>
          ) : (
            <div className="flex gap-2">
              <button
                type="button"
                onClick={() => setStep(1)}
                className="btn btn-secondary flex-1"
              >
                Précédent
              </button>
              <button type="submit" className="btn btn-primary flex-1">
                S'inscrire
              </button>
            </div>
          )}
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
