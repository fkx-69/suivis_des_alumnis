"use client";
import { usePathname, useRouter } from "next/navigation";
import { AuthProvider, useAuth } from "@/lib/api/authContext";
import { useEffect } from "react";


export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <AuthProvider>
      <AuthGuard>{children}</AuthGuard>
    </AuthProvider>
  );
}

function AuthGuard({ children }: { children: React.ReactNode }) {
  const { user, loading } = useAuth();
  const router = useRouter();
  const pathname = usePathname();

  useEffect(() => {
    if (user) {
      router.push("/");
    }
  }, [loading, user, pathname, router]);

  if (loading) {
    return null;
  }

  return <>{children}</>;
}
