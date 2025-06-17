"use client";
import { useEffect, useState } from "react";
import UserCard from "@/components/UserCard";
import { Input } from "@/components/ui/Input";
import { api } from "@/lib/api/axios";
import { User } from "@/types/auth";

export default function UsersListPage() {
  const [users, setUsers] = useState<User[]>([]);
  const [search, setSearch] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const timer = setTimeout(() => {
      const fetchUsers = async () => {
        setLoading(true);
        setError(null);
        try {
          const res = await api.get<User[]>("/accounts/rechercher-utilisateur/", {
            params: search ? { search } : {},
          });
          setUsers(res.data);
        } catch (err: any) {
          setError(err.message);
        } finally {
          setLoading(false);
        }
      };
      fetchUsers();
    }, 300);
    return () => clearTimeout(timer);
  }, [search]);

  return (
    <main className="p-4 space-y-4">
      <div className="max-w-md">
        <Input
          placeholder="Rechercher..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
        />
      </div>
      {loading && (
        <div className="flex justify-center">
          <span className="loading loading-spinner" />
        </div>
      )}
      {error && <div className="alert alert-error">{error}</div>}
      <div className="grid gap-4 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4">
        {users.map((u) => (
          <UserCard key={u.id} user={u} />
        ))}
      </div>
    </main>
  );
}
