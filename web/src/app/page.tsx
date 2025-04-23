import Link from "next/link";

export default function Home() {
  return (
    <div className="h-screen flex flex-col items-center justify-center bg-gray-50">
      <h1 className="text-4xl font-bold mb-8">
        Bienvenue sur notre plateforme
      </h1>
      <div className="space-x-4">
        <Link
          href="/login"
          className="px-6 py-3 bg-blue-600 hover:bg-blue-700 text-white font-medium rounded-lg"
        >
          Connexion
        </Link>
        <Link
          href="/signIn"
          className="px-6 py-3 bg-green-600 hover:bg-green-700 text-white font-medium rounded-lg"
        >
          S'inscrire
        </Link>
      </div>
    </div>
  );
}
