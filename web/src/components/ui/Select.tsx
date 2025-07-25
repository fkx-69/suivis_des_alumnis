// components/ui/Select.tsx
export interface SelectOption<T = string> {
  value: T;
  label: string;
}

export interface SelectProps<T = string>
  extends React.SelectHTMLAttributes<HTMLSelectElement> {
  label?: string;
  options: SelectOption<T>[];
  error?: string;
}

