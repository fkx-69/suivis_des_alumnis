"use client";

import ProfileDetails from '@/components/profile/ProfileDetails';
import UserPublicationsList from '@/components/profile/UserPublicationsList';
import NotificationsList from '@/components/profile/NotificationsList';
import MentoratRequests from '@/components/profile/MentoratRequests';

export default function ProfilePage() {
  return (
    <div className="p-4 md:p-8">
      <h1 className="text-3xl font-bold mb-8">Mon Espace Personnel</h1>
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">

        {/* Colonne principale pour les détails du profil et les publications */}
        <div className="lg:col-span-2 space-y-8">
          <ProfileDetails />
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
