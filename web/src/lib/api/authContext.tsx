// context/AuthContext.tsx
import {
  createContext,
  ReactNode,
  useContext,
  useEffect,
  useState,
} from "react";
import { User, LoginPayload } from "@/types/auth";
import { api } from "@/lib/api/axios";
import { login as loginApi } from "@/lib/api/auth";

interface AuthContextType {
  user: User | null;
  loading: boolean;
  login: (credentials: LoginPayload) => Promise<void>;
  logout: () => Promise<void>;
  updateUser: (user: User) => void;
}

const AuthContext = createContext<AuthContextType>({
  user: null,
  loading: true,
  login: async (credentials: LoginPayload) => {
    console.warn(
      "Login function called on default AuthContext: no AuthProvider found in tree.",
      credentials
    );
    throw new Error("AuthProvider not found");
  },
  logout: async () => {
    console.warn(
      "Logout function called on default AuthContext: no AuthProvider found in tree."
    );
  },
  updateUser: (user: User) => {
    console.warn(
      "updateUser function called on default AuthContext: no AuthProvider found in tree.",
      user
    );
  },
});

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const checkUser = async () => {
      try {
        const res = await api.get("/accounts/me");
        setUser(res.data as User);
      } catch {
        setUser(null);
      } finally {
        setLoading(false);
      }
    };
    checkUser();
  }, []);

  const login = async (credentials: LoginPayload) => {
    try {
      const response = await loginApi(credentials);
      localStorage.setItem("token", response.access);
      api.defaults.headers.common["Authorization"] = `Bearer ${response.access}`;
      setUser(response.user);
    } catch (error) {
      setUser(null);
      console.error("Login failed:", error);
      throw error;
    }
  };

  const logout = async () => {
    try {
      await api.post("/accounts/logout/", {});
    } catch (error) {
      console.error("Logout API call failed:", error);
    } finally {
      localStorage.removeItem("token");
      delete api.defaults.headers.common["Authorization"];
      setUser(null);
    }
  };

  const updateUser = (userData: User) => {
    setUser(userData);
  };

  const contextValue = {
    user,
    loading,
    login,
    logout,
    updateUser,
  };

  return (
    <AuthContext.Provider value= { contextValue } > { children } </AuthContext.Provider>
  );
}

// useAuth hook now directly returns AuthContextType due to the default context value.
export const useAuth = () => useContext(AuthContext);
