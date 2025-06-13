// components/ui/toast.tsx
import { toast as sonnerToast } from "sonner"; // shadcn utilise Sonner

export const toast = {
  success: (msg: string) => sonnerToast.success(msg),
  error: (msg: string) => sonnerToast.error(msg),
};
