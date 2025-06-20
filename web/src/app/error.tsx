'use client';
import { useEffect } from 'react';
import Link from 'next/link';

export default function GlobalError({ error, reset }: { error: Error; reset: () => void }) {
  useEffect(() => {
    console.error(error);
  }, [error]);

  return (
    <div className="h-screen flex flex-col items-center justify-center bg-base-100 mx-auto max-w-7xl px-4">
      <h1 className="text-4xl font-bold mb-4">Une erreur est survenue</h1>
      <button className="btn btn-primary btn-lg" onClick={() => reset()}>
        Réessayer
      </button>
      <Link href="/" className="btn btn-link mt-4">
        Retour à l'accueil
      </Link>
    </div>
  );
}
