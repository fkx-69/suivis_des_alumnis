// components/ui/Input.tsx
import React from "react";
import { cn } from "@/lib/utils";
// Importing globals.css here is generally not needed if it's imported at the root layout level.
// import "@/app/globals.css";

export interface InputProps
  extends React.InputHTMLAttributes<HTMLInputElement> {
  label?: string;
  error?: string;
}

export const Input = React.forwardRef<HTMLInputElement, InputProps>(
  // Renamed the destructured 'className' prop to 'propClassName' to avoid ambiguity
  // if 'className' also exists within '...props' (though less likely with explicit destructuring).
  ({ label, error, className: propClassName, ...props }, ref) => (
    <label className="block mb-2 text-sm font-medium">
      {label && <span className="">{label}</span>}
      <input
        ref={ref}
        className={cn(
          "w-full", // Base utility class
          "input", // DaisyUI base input class
          error ? "input-error" : "input-primary", // Conditional DaisyUI classes
          propClassName // Classes passed as a prop to the Input component
        )}
        {...props}
      />
      {error && <span className="text-xs text-red-500">{error}</span>}
    </label>
  )
);
Input.displayName = "Input";
