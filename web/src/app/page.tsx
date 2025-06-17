import Link from "next/link";

export default function Home() {
  return (
    <div className="h-screen flex flex-col items-center justify-center bg-base-100">
      <h1 className="text-4xl font-bold mb-8">
        Bienvenue sur notre plateforme
      </h1>
      <div className="space-x-4">
        <Link href="auth/login" className="btn btn-primary btn-lg">
          Connexion
        </Link>
        <Link href="auth/signIn" className="btn btn-accent btn-lg">
          S'inscrire
        </Link>
      </div>
    </div>
  );
}
