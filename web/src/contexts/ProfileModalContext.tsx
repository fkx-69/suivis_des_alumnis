"use client";

import React, { createContext, useState, useContext, ReactNode } from 'react';
import { fetchUserProfile, UserProfile } from '@/lib/api/users';
import ExternalProfileModal from '@/components/ExternalProfileModal';

interface ProfileModalContextType {
  showProfile: (username: string) => void;
}

const ProfileModalContext = createContext<ProfileModalContextType | undefined>(undefined);

export const useProfileModal = () => {
  const context = useContext(ProfileModalContext);
  if (!context) {
    throw new Error('useProfileModal must be used within a ProfileModalProvider');
  }
  return context;
};

export const ProfileModalProvider = ({ children }: { children: ReactNode }) => {
  const [userProfile, setUserProfile] = useState<UserProfile | null>(null);
  const [isLoading, setIsLoading] = useState(false);

  const showProfile = async (username: string) => {
    setIsLoading(true);
    try {
      const profile = await fetchUserProfile(username);
      setUserProfile(profile);
    } catch (error) {
      console.error("Failed to fetch user profile:", error);
      // Optionnel: afficher une notification d'erreur
    } finally {
      setIsLoading(false);
    }
  };

  const hideProfile = () => {
    setUserProfile(null);
  };

  return (
    <ProfileModalContext.Provider value={{ showProfile }}>
      {children}
      {userProfile && (
        <ExternalProfileModal user={userProfile} onClose={hideProfile} />
      )}
      {/* Optionnel: afficher un indicateur de chargement global */}
      {isLoading && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/20">
          <span className="loading loading-spinner loading-lg"></span>
        </div>
      )}
    </ProfileModalContext.Provider>
  );
};
