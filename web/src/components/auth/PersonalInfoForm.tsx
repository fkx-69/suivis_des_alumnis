'use client';
import React from 'react';
import { Input } from '@/components/ui/Input';
import type { UserForm } from '@/types/auth';

export interface MessageError {
  [key: string]: string[];
}

interface Props {
  user: UserForm;
  confirmPassword: string;
  isPasswordEqual: boolean;
  messageError: MessageError;
  onUserChange: (e: React.ChangeEvent<HTMLInputElement>) => void;
  onConfirmPasswordChange: (e: React.ChangeEvent<HTMLInputElement>) => void;
}

export default function PersonalInfoForm({
  user,
  confirmPassword,
  isPasswordEqual,
  messageError,
  onUserChange,
  onConfirmPasswordChange,
}: Props) {
  return (
    <fieldset className="space-y-4">
      <div className="grid grid-cols-2 gap-4">
        <Input
          label="Nom"
          name="nom"
          value={user.nom}
          onChange={onUserChange}
          required
          className="input input-primary"
          error={messageError.nom?.join(', ')}
        />
        <Input
          label="Prénom"
          name="prenom"
          value={user.prenom}
          onChange={onUserChange}
          required
          className="input input-primary"
          error={messageError.prenom?.join(', ')}
        />
      </div>
      <div className="grid grid-cols-2 gap-4">
        <Input
          label="Email"
          type="email"
          name="email"
          value={user.email}
          onChange={onUserChange}
          required
          className="input input-primary"
          error={messageError.email?.join(', ')}
        />
        <Input
          label="Nom d'utilisateur"
          name="username"
          value={user.username}
          onChange={onUserChange}
          required
          className="input input-primary"
          error={messageError.username?.join(', ')}
        />
      </div>
      <div className="grid grid-cols-2 gap-4">
        <Input
          label="Mot de passe"
          type="password"
          name="password"
          value={user.password}
          onChange={onUserChange}
          required
          className={isPasswordEqual ? 'input input-primary' : 'input input-error'}
        />
        <Input
          label="Confirmer le mot de passe"
          type="password"
          name="confirmPassword"
          value={confirmPassword}
          onChange={onConfirmPasswordChange}
          required
          className={isPasswordEqual ? 'input input-primary' : 'input input-error'}
        />
      </div>
      {!isPasswordEqual && (
        <p className="text-error">Les mots de passe ne correspondent pas.</p>
      )}
    </fieldset>
  );
}
