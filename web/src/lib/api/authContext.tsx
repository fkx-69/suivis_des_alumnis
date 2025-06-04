// context/AuthContext.tsx
import {
  createContext,
  ReactNode,
  useContext,
  useEffect,
  useState,
} from "react";
import { User } from "@/types/auth"; // Adjust the import path as necessary
import { api } from "@/lib/api/axios"; // Using the configured axios instance

// It's highly recommended to replace 'any' with your actual User type.
// You might have this defined in 'src/types/auth.d.ts'.
// e.g., import type { User } from '@/types/auth';

interface AuthContextType {
  user: User | null;
  loading: boolean;
  login: (userData: User) => void;
  logout: () => Promise<void>;
}

// Provide a default context value that matches the AuthContextType.
// This helps with type safety and provides default behavior if consumed outside a provider.
const AuthContext = createContext<AuthContextType>({
  user: null,
  loading: true, // Default to loading true, as useEffect will set it
  login: (userData: User) => {
    // This default implementation should ideally not be called.
    // It's a fallback if the context is used without a Provider.
    console.warn(
      "Login function called on default AuthContext: no AuthProvider found in tree.",
      userData
    );
  },
  logout: async () => {
    console.warn(
      "Logout function called on default AuthContext: no AuthProvider found in tree."
    );
  },
});

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  // Appel API pour vérifier l'utilisateur connecté
  useEffect(() => {
    api // Use the configured 'api' instance
      .get("/api/me", { withCredentials: true }) // Pass withCredentials if not globally set in 'api' instance
      .then((res) => {
        setUser(res.data as User); // It's good practice to validate or cast res.data
      })
      .catch(() => {
        setUser(null); // User not authenticated or error fetching
      })
      .finally(() => {
        setLoading(false);
      });
  }, []);

  const login = (userData: User) => {
    // Corrected parameter type
    setUser(userData);
  };

  const logout = async () => {
    // Made async, improved API call structure
    try {
      // Corrected api.get usage: url and config object
      await api.get("/api/logout", { withCredentials: true });
    } catch (error) {
      console.error("Logout API call failed:", error);
      // Depending on requirements, you might want to re-throw or handle this error differently
    } finally {
      setUser(null); // Ensure local state is cleared
    }
  };

  const contextValue = {
    user,
    loading,
    login,
    logout,
  };

  return (
    <AuthContext.Provider value={contextValue}>{children}</AuthContext.Provider>
  );
}

// useAuth hook now directly returns AuthContextType due to the default context value.
export const useAuth = () => useContext(AuthContext);
