"use client";
import { User } from "@/types/auth";

interface UserCardProps {
  user: User;
}

export default function UserCard({ user }: UserCardProps) {
  return (
    <div className="card bg-base-100 shadow-sm">
      <div className="card-body flex items-center gap-4">
        <div className="avatar">
          <div className="w-12 rounded-full bg-base-200 overflow-hidden">
            {user.photo_profil ? (
              // eslint-disable-next-line @next/next/no-img-element
              <img src={user.photo_profil} alt={user.username} />
            ) : (
              <span className="flex items-center justify-center w-full h-full font-semibold">
                {user.username.charAt(0).toUpperCase()}
              </span>
            )}
          </div>
        </div>
        <div>
          <h2 className="font-semibold">
            {user.prenom} {user.nom}
          </h2>
          <p className="text-sm opacity-70">
            @{user.username} - {user.role}
          </p>
        </div>
      </div>
    </div>
  );
}
