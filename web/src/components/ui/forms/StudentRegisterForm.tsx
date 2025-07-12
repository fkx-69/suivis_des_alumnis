/* eslint-disable */
// @ts-nocheck
"use client";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { registerStudent } from "@/lib/api/auth";
import { fetchFilieres } from "@/lib/api/filiere";
import { register } from "module";
import React from "react";
import { SelectOption, Select } from "../Select";
import { Controller } from "react-hook-form";
const { control /* ... */ } = useForm();

/*
const schema = z
  .object({
    email: z.string().email(),
    username: z.string().min(3),
    nom: z.string(),
    prenom: z.string(),
    password: z.string().min(8),
    confirmPassword: z.string(),
    filiere: z.string().min(2),
    niveau_etude: z.string(),
    annee_entree: z.coerce.number().gte(1900).lte(new Date().getFullYear()),
    need_mentor: z.boolean(),
  })
  .refine((data) => data.password === data.confirmPassword, {
    message: "Les mots de passe ne correspondent pas",
    path: ["confirmPassword"],
  });

type FormData = z.infer<typeof schema>;

const [filieres, setFilieres] = React.useState<SelectOption[]>([]);

React.useEffect(() => {
  fetchFilieres().then((data) =>
    setFilieres(data.map((f) => ({ value: f.code, label: f.nom_complet })))
  );
}, []);
<Controller
  control={control}
  name="filiere"
  render={({ field }) => (
    <Select label="Filière" options={filieres} {...field} />
  )}
/>;

export default function StudentRegisterForm() {
  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<FormData>({ resolver: zodResolver(schema) });

  const onSubmit = async (data: FormData) => {
    await registerStudent({ ...data });
    // TODO : redirect ou toast success
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="space-y-4 max-w-md">
      <label>Email </label>
      <input />
      {/* autres champs }
      <button
        type="submit"
        disabled={isSubmitting}
        className=" btn btn-primary w-full"
      >
        Créer le compte
      </button>
    </form>
  );
}
*/
