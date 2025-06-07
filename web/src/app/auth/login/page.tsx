"use client";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { login } from "@/lib/api/auth";
import { useAuth } from "@/lib/store/auth";
import { Input } from "@/components/ui/Input";
import { toast } from "@/components/ui/toast";
import "@/app/globals.css";

const schema = z.object({
  email: z.string().email({ message: "Email invalide" }),
  password: z.string().min(1, "Mot de passe requis"),
});

type FormData = z.infer<typeof schema>;

export default function LoginPage() {
  const setUser = useAuth((s) => s.setUser);
  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<FormData>({ resolver: zodResolver(schema) });

  const onSubmit = async (data: FormData) => {
    try {
      const response = await login(data);
      const user = { id: response.user.id, username: response.user.username }; // Ensure the response matches the expected type
      setUser(user);
      toast.success("Connexion réussie");
    } catch {
      toast.error("Identifiants incorrects");
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-base-200">
      <div className="bg-s p-8 rounded-2xl shadow-xl w-full max-w-md bg-base-100">
        <h2 className="text-2xl font-bold mb-6 text-center">Connexion</h2>
        <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
          <fieldset className="space-y-4">
            <Input
              className="input input-primary"
              label="Email"
              {...register("email")}
              error={errors.email?.message}
            />
            <Input
              className="input input-primary"
              type="password"
              label="Mot de passe"
              {...register("password")}
              error={errors.password?.message}
            />
          </fieldset>
          <button
            type="submit"
            disabled={isSubmitting}
            className="btn btn-primary px-4 py-2 border rounded-xl transition duration-200 justify-center w-full"
          >
            Connexion
          </button>
        </form>
        <div className="mt-4 text-sm text-center text-gray-500">
          Vous n'avez pas de compte ?{" "}
          <a href="/signIn" className="text-blue-600 hover:underline">
            Inscrivez-vous
          </a>
        </div>
      </div>
    </div>
  );
}
