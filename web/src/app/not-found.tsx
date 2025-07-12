import Link from "next/link";

export default function NotFound() {
  return (
    <div className="h-screen flex flex-col items-center justify-center bg-base-100 mx-auto max-w-7xl px-4">
      <h1 className="text-4xl font-bold mb-8">Page introuvable</h1>
      <Link href="/" className="btn btn-primary btn-lg">
        Retour à l&apos;accueil
      </Link>
    </div>
  );
}
