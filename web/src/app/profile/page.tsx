"use client";

import { useEffect, useState } from "react";
import ProfileDetails from "@/components/profile/ProfileDetails";
import UserPublicationsList from "@/components/profile/UserPublicationsList";
import NotificationsList from "@/components/profile/NotificationsList";
import MentoratRequests from "@/components/profile/MentoratRequests";
import ParcoursSection from "@/components/profile/ParcoursSection";
import {
  fetchParcoursAcademiques,
  fetchParcoursProfessionnels,
} from "@/lib/api/parcours";
import { ParcoursAcademique, ParcoursProfessionnel } from "@/types/parcours";
import { useAuth } from "@/lib/api/authContext";

export default function ProfilePage() {
  const { user } = useAuth();
  const [parcoursAcad, setParcoursAcad] = useState<ParcoursAcademique[]>([]);
  const [parcoursPro, setParcoursPro] = useState<ParcoursProfessionnel[]>([]);

  const refreshParcours = () => {
    if (user?.role?.toUpperCase() === "ALUMNI") {
      fetchParcoursAcademiques().then(setParcoursAcad);
      fetchParcoursProfessionnels().then(setParcoursPro);
    }
  };

  useEffect(() => {
    refreshParcours();
  }, [user]);

  return (
    <div className="p-4 md:p-8">
      <h1 className="text-3xl font-bold mb-8">Mon Espace Personnel</h1>
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        {/* Colonne principale pour les détails du profil et les publications */}
        <div className="lg:col-span-2 space-y-8">
          <ProfileDetails />
          {user?.role?.toUpperCase() === "ALUMNI" && (
            <ParcoursSection
              academicItems={parcoursAcad}
              professionalItems={parcoursPro}
              onChanged={refreshParcours}
            />
          )}
          <UserPublicationsList />
        </div>

        {/* Colonne latérale pour les notifications et le mentorat */}
        <div className="space-y-8">
          <div className="bg-base-100 p-6 rounded-2xl shadow-lg">
            <NotificationsList />
          </div>
          <div className="bg-base-100 p-6 rounded-2xl shadow-lg">
            <MentoratRequests />
          </div>
        </div>
      </div>
    </div>
  );
}
