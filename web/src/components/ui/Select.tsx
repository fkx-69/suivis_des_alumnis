// components/ui/Select.tsx
export interface SelectOption<T = string> {
  value: T;
  label: string;
}

interface SelectProps<T = string>
  extends React.SelectHTMLAttributes<HTMLSelectElement> {
  label?: string;
  options: SelectOption<T>[];
  error?: string;
}

export function Select<T = string>({
  label,
  options,
  error,
  ...props
}: SelectProps<T>) {
  return (
    <label className="w-full space-y-1">
      {label && <span className="text-sm font-medium">{label}</span>}
      <select
        className={"w-full  select" + error ? "select-error" : "select-primary"}
        {...props}
      >
        <option value="">Sélectionnez…</option>
        {options.map((opt) => (
          <option key={String(opt.value)} value={String(opt.value)}>
            {opt.label}
          </option>
        ))}
      </select>
      {error && <span className="text-xs text-red-500">{error}</span>}
    </label>
  );
}
