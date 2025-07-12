import { useTheme } from "next-themes";
import { Moon, Sun } from "lucide-react";
import { useEffect, useState } from "react";

export default function ThemeToggle({
  collapsed = false,
}: {
  collapsed?: boolean;
}) {
  const { theme, resolvedTheme, setTheme } = useTheme();
  const [mounted, setMounted] = useState(false);

  useEffect(() => setMounted(true), []);

  if (!mounted) return null;

  const toggle = () => {
    const current = resolvedTheme || theme;
    const newTheme = current === "itma-dark" ? "itma" : "itma-dark";
    setTheme(newTheme);
    if (typeof document !== "undefined") {
      document.documentElement.setAttribute("data-theme", newTheme);
    }
  };

  return (
    <button
      aria-label="Toggle Theme"
      className="btn btn-ghost w-full flex items-center justify-center"
      onClick={toggle}
      type="button"
      data-testid="theme-toggle-button"
    >
      {(resolvedTheme || theme) === "itma" ? (
        <Sun size={20} />
      ) : (
        <Moon size={20} />
      )}
      {!collapsed && <span className="hidden sm:inline">Thème</span>}
    </button>
  );
}
