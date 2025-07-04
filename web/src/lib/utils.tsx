// lib/utils.ts
import { clsx, ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";

/**
 * Concatène des classes (clsx) **puis** fusionne / dé-duplique intelligemment
 * les classes utilitaires Tailwind (twMerge).
 *
 * @example
 *  cn("px-2 py-1", condition && "bg-primary", "px-4") // → "py-1 bg-primary px-4"
 */
export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

export function formatTimeAgo(dateString: string): string {
  const now = new Date();
  const date = new Date(dateString);
  const secondsPast = (now.getTime() - date.getTime()) / 1000;

  if (secondsPast < 60) return "à l'instant";
  if (secondsPast < 3600) return `${Math.floor(secondsPast / 60)} min`;
  if (secondsPast <= 86400) return `${Math.floor(secondsPast / 3600)} h`;
  const days = Math.floor(secondsPast / 86400);
  if (days === 1) return "hier";
  if (days <= 7) return `${days} j`;

  return new Intl.DateTimeFormat("fr-FR", {
    day: "2-digit",
    month: "2-digit",
    year: "numeric",
  }).format(date);
}
