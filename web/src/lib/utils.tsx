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
