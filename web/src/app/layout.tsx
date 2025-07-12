"use client";
import type { Metadata } from "next";
// Disabled next/font usage to avoid network font fetching during build
import "./globals.css";
import SidePanel from "../components/ui/side-bar";
import { usePathname, useRouter } from "next/navigation";
import { AuthProvider, useAuth } from "@/lib/api/authContext";
import { ProfileModalProvider } from "@/contexts/ProfileModalContext";

import { useEffect } from "react";
import { ThemeProvider } from "next-themes";

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  const pathname = usePathname();
  const showSidePanel =
    pathname !== "/auth/login" && pathname !== "/auth/signIn";
  return (
    <html lang="fr" suppressHydrationWarning>
      <body className="antialiased">
        <ThemeProvider
          attribute="data-theme"
          defaultTheme="itma"
          enableSystem={false}
        >
          <AuthProvider>
            <ProfileModalProvider>
              <AuthGuard>
                {showSidePanel ? <SidePanel>{children}</SidePanel> : children}
              </AuthGuard>
            </ProfileModalProvider>
          </AuthProvider>
        </ThemeProvider>
      </body>
    </html>
  );
}

function AuthGuard({ children }: { children: React.ReactNode }) {
  const { user, loading } = useAuth();
  const router = useRouter();
  const pathname = usePathname();

  const publicPaths = ["/auth/login", "/auth/signIn"];

  useEffect(() => {
    if (loading) return; // Do nothing while loading

    const isPublic = publicPaths.includes(pathname);

    if (!user && !isPublic) {
      router.push("/auth/login");
    } else if (
      user &&
      (pathname === "/auth/login" || pathname === "/auth/signIn")
    ) {
      router.push("/");
    }
  }, [user, loading, pathname, router, publicPaths]);

  if (
    loading ||
    (!user && !publicPaths.includes(pathname)) ||
    (user && (pathname === "/auth/login" || pathname === "/auth/signIn"))
  ) {
    return (
      <div className="flex justify-center items-center h-screen">
        <span className="loading loading-spinner loading-lg"></span>
      </div>
    );
  }

  return <>{children}</>;
}
