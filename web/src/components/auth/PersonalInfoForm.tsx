"use client";
import React from "react";
import { Input } from "@/components/ui/Input";
import { useFormContext } from "react-hook-form";
import { RegisterFormValues } from "@/lib/validators/auth";

export default function PersonalInfoForm({ error }: { error?: string }) {
  const {
    register,
    formState: { errors },
  } = useFormContext<RegisterFormValues>();
  return (
    <fieldset className="space-y-4">
      <div className="grid grid-cols-2 gap-4">
        <Input
          label="Nom"
          {...register("nom")}
          required
          className="input input-primary"
          error={errors.nom?.message}
        />
        <Input
          label="Prénom"
          {...register("prenom")}
          required
          className="input input-primary"
          error={errors.prenom?.message}
        />
      </div>
      <div className="grid grid-cols-2 gap-4">
        <Input
          label="Email"
          type="email"
          {...register("email")}
          required
          className="input input-primary"
          error={errors.email?.message}
        />
        <Input
          label="Nom d'utilisateur"
          {...register("username")}
          required
          className="input input-primary"
          error={errors.username?.message}
        />
      </div>
      <div className="grid grid-cols-2 gap-4">
        <Input
          label="Mot de passe"
          type="password"
          {...register("password")}
          required
          className={`input input-primary ${errors.password ? "input-error" : ""}`}
          error={errors.password?.message}
        />
        <Input
          label="Confirmer le mot de passe"
          type="password"
          {...register("confirmPassword")}
          required
          className={`input input-primary ${errors.confirmPassword ? "input-error" : ""}`}
          error={errors.confirmPassword?.message}
        />
      </div>
      {error && <p className="text-error text-sm">{error}</p>}
    </fieldset>
  );
}
