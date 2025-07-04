import { useTheme } from "next-themes";
import { Moon, Sun } from "lucide-react";
import { useEffect, useState } from "react";

export default function ThemeToggle() {
  const { theme, setTheme } = useTheme();
  const [mounted, setMounted] = useState(false);

  useEffect(() => setMounted(true), []);

  if (!mounted) return null;

  const toggle = () => setTheme(theme === "dark" ? "emerald" : "dark");

  return (
    <button
      aria-label="Toggle Theme"
      className="btn btn-ghost w-full flex items-center justify-center gap-3"
      onClick={toggle}
    >
      {theme === "dark" ? <Sun size={20} /> : <Moon size={20} />}
      <span className="hidden sm:inline">Thème</span>
    </button>
  );
}
