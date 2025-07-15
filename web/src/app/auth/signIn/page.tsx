"use client";

import { useState, useEffect } from "react";

import { useForm, FormProvider } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { registerAlumni, registerStudent } from "@/lib/api/auth";
import { useAuth } from "@/lib/api/authContext";
import { fetchFilieres, Filiere } from "@/lib/api/filiere";
import { useRouter } from "next/navigation";
import Link from "next/link";
import axios from "axios";
import PersonalInfoForm from "@/components/auth/PersonalInfoForm";
import AlumniForm from "@/components/auth/AlumniForm";
import StudentForm from "@/components/auth/StudentForm";
import { registerFormSchema, RegisterFormValues } from "@/lib/validators/auth";

export default function SignIn() {
  const { login, updateUser } = useAuth();
  const router = useRouter();
  const [step, setStep] = useState(1);
  const [filieres, setFilieres] = useState<Filiere[]>([]);
  const [serverError, setServerError] = useState<string | null>(null);
  // Ajout d'un état pour stocker toutes les erreurs de validation
  const [allErrors, setAllErrors] = useState<string[]>([]);

  const methods = useForm<RegisterFormValues>({
    resolver: zodResolver(registerFormSchema),
    defaultValues: {
      userType: "alumni",
      role: "alumni",
      filiere: "",
      situation_pro: "chomage",
      secteur_activite: "autres",
      poste_actuel: "Autres",
    },
    mode: "onTouched", // pour afficher les erreurs dès qu'un champ est touché
    criteriaMode: "all", // pour avoir toutes les erreurs
  });

  const { register, handleSubmit, watch, setValue, setError, trigger, formState, getValues } = methods;
  const userType = watch("userType");

  useEffect(() => {
    setValue("role", userType);
  }, [userType, setValue]);

  useEffect(() => {
    fetchFilieres()
      .then((data) => {
        setFilieres(data);
        if (data.length > 0) {
          setValue("filiere", String(data[0].id), { shouldValidate: true });
        }
      })
      .catch((err) => console.error("Failed to fetch filieres:", err));
  }, [setValue]);

  // Fonction utilitaire pour extraire toutes les erreurs du formState
  function extractAllErrors(errorsObj: any): string[] {
    if (!errorsObj) return [];
    let result: string[] = [];
    for (const key in errorsObj) {
      if (errorsObj[key]?.message) {
        result.push(errorsObj[key].message);
      }
      if (errorsObj[key]?.types) {
        result = result.concat(Object.values(errorsObj[key].types));
      }
      if (typeof errorsObj[key] === "object" && errorsObj[key] !== null) {
        result = result.concat(extractAllErrors(errorsObj[key]));
      }
    }
    return result;
  }

  const handleNext = async () => {
    setServerError(null);
    setAllErrors([]);
    const fieldsToValidate: (keyof RegisterFormValues)[] = [
      "nom",
      "prenom",
      "email",
      "username",
      "password",
      "confirmPassword",
    ];
    const isValid = await trigger(fieldsToValidate);
    if (!isValid) {
      setAllErrors(extractAllErrors(formState.errors));
    } else {
      setStep(2);
    }
  };

  const onSubmit = async (formData: RegisterFormValues) => {
    setServerError(null);
    setAllErrors([]);
    // Log pour debug
    console.log("Form submit:", formData);
    try {
      const { nom, prenom, email, username, password } = formData;
      const user = { nom, prenom, email, username, password };
      let response;
      if (formData.userType === "alumni") {
        const { confirmPassword, userType, ...alumniData } = formData;
        // Suppression des champs si situation_pro === 'chomage'
        let payload = { ...alumniData, user };
        if (formData.situation_pro === "chomage") {
          const { secteur_activite, poste_actuel, nom_entreprise, ...rest } = payload;
          payload = { ...rest };
        }
        response = await registerAlumni(payload);
      } else {
        const { confirmPassword, userType, ...studentData } = formData;
        const payload = {
          ...studentData,
          annee_entree: Number(studentData.annee_entree),
          user,
        };
        response = await registerStudent(payload);
      }
      try {
        await login({ email, password });
        if (response.data.user) {
          updateUser(response.data.user);
        }
        router.push("/");
      } catch (loginError) {
        console.error("Auto login failed:", loginError);
        router.push("/auth/login");
      }
      await login({ email, password });
      router.push("/");
    } catch (err) {
      if (axios.isAxiosError(err) && err.response) {
        const { status, data: errorData } = err.response;
        if (status === 400) {
          const serverErrors = (errorData.user ?? errorData) as Record<string, string[]>;
          const remainingErrors: string[] = [];
          Object.entries(serverErrors).forEach(([field, messages]) => {
            if (field in formData) {
              setError(field as keyof RegisterFormValues, {
                type: "server",
                message: messages.join(", "),
              });
            } else {
              remainingErrors.push(messages.join(", "));
            }
          });
          if (remainingErrors.length) {
            setServerError(remainingErrors.join(" \n"));
          }
          setAllErrors(extractAllErrors(formState.errors));
          return;
        }
        const message = errorData.detail || errorData.message;
        if (message) {
          setServerError(message);
          setAllErrors([message]);
          return;
        }
      }
      console.error(err);
      setServerError("Une erreur inattendue est survenue.");
      setAllErrors(["Une erreur inattendue est survenue."]);
    }
  };

  return (
    <div className="min-h-dvh flex w-full items-center justify-center bg-base-200 mx-auto max-w-7xl px-4">
      <div className="p-8 rounded-2xl shadow-xl w-full bg-base-100 transition-all duration-500 ease-in-out max-w-2xl">
        <h1 className="text-2xl font-semibold mb-6 text-center text-base-content">
          Inscription
        </h1>

        {/* Affichage global des erreurs de validation */}
        {(allErrors.length > 0 || serverError) && (
          <div className="mb-4">
            <div className="bg-red-100 border border-red-400 text-red-700 px-4 py-2 rounded">
              <ul className="list-disc pl-5">
                {allErrors.map((err, i) => (
                  <li key={i}>{err}</li>
                ))}
                {serverError && <li>{serverError}</li>}
              </ul>
            </div>
          </div>
        )}

        <FormProvider {...methods}>
          <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
            <div className="form-control">
              <label className="block mb-1 text-base-content">
                Type d&apos;utilisateur
              </label>
              <select
                className="select select-primary w-full"
                {...register("userType")}
              >
                <option value="alumni">Alumni</option>
                <option value="student">Étudiant</option>
              </select>
            </div>

            {step === 1 && (
              <PersonalInfoForm error={serverError ?? undefined} />
            )}

            {step === 2 &&
              (userType === "alumni" ? (
                <AlumniForm
                  filieres={filieres}
                  error={serverError ?? undefined}
                />
              ) : (
                <StudentForm
                  filieres={filieres}
                  error={serverError ?? undefined}
                />
              ))}

            {step === 1 ? (
              <button
                type="button"
                onClick={handleNext}
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
                  S&apos;inscrire
                </button>
              </div>
            )}
          </form>
        </FormProvider>

        <div className="mt-4 text-sm text-center text-gray-500">
          Vous avez déjà un compte ?{" "}
          <Link href="/auth/login" className="text-blue-600 hover:underline">
            Connectez-vous
          </Link>
        </div>
      </div>
    </div>
  );
}
