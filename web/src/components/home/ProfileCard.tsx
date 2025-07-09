import Link from "next/link";

interface SuggestedUser {
  username: string;
  prenom: string;
  nom: string;
  photo_profil: string | null;
}

interface ProfileCardProps {
  user: SuggestedUser;
}

export default function ProfileCard({ user }: ProfileCardProps) {
  const photoUrl = user.photo_profil
    ? user.photo_profil
    : `https://ui-avatars.com/api/?name=${user.prenom}+${user.nom}&background=random`;

  return (
    <div className="carousel-card snap-center flex-shrink-0 card bg-base-200 shadow-md hover:shadow-lg transition-shadow duration-300 text-center items-center p-4 w-[220px]">
      <div className="avatar mb-4">
        <div className="w-16 h-16 rounded-full ring ring-primary ring-offset-base-100 ring-offset-2">
          <img src={photoUrl} alt={`Profil de ${user.prenom}`} />
        </div>
      </div>
      <h3 className="text-base font-bold">
        {user.prenom} {user.nom}
      </h3>
      <p className="text-xs text-base-content/70">@{user.username}</p>
      <div className="card-actions mt-4">
        <Link
          href={`/profile/${user.username}`}
          className="btn btn-primary btn-sm"
        >
          Voir Profil
        </Link>
      </div>
    </div>
  );
}
