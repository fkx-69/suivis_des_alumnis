import { z } from 'zod';

// Schéma pour la validation du mot de passe
const passwordSchema = z.string().min(8, "Le mot de passe doit contenir au moins 8 caractères.");

// Schéma de base contenant les champs communs
const baseSchema = z.object({
    nom: z.string().min(2, "Le nom doit contenir au moins 2 caractères."),
    prenom: z.string().min(2, "Le prénom doit contenir au moins 2 caractères."),
    email: z.string().email("L'adresse email est invalide."),
    username: z.string().min(3, "Le nom d'utilisateur doit contenir au moins 3 caractères."),
    password: passwordSchema,
    confirmPassword: passwordSchema,
    filiere: z.string({ required_error: "La filière est requise." }).min(1, "La filière est requise."),
});

// Schéma pour l'alumni, étendant le schéma de base
export const alumniSchema = baseSchema.extend({
    userType: z.literal('alumni'),
    date_fin_cycle: z.string({ required_error: "L'année de fin de cycle est requise." }).min(4, "L'année de fin de cycle est requise."),
    situation_pro: z.string({ required_error: "La situation professionnelle est requise." }),
    secteur_activite: z.string().optional(),
    poste_actuel: z.string().optional(),
    nom_entreprise: z.string().optional(),
    role: z.literal("alumni"),
});

// Schéma pour l'étudiant, étendant le schéma de base
export const studentSchema = baseSchema.extend({
    userType: z.literal('student'),
    niveau_etude: z.string({ required_error: "Le niveau d'étude est requis." }),
    annee_entree: z.string({ required_error: "L'année d'entrée est requise." }),
    role: z.literal("student"),
});


// Union discriminée des deux schémas
export const registerFormSchema = z.discriminatedUnion('userType', [
    alumniSchema,
    studentSchema
]).refine(data => data.password === data.confirmPassword, {
    message: "Les mots de passe ne correspondent pas.",
    path: ["confirmPassword"], // L'erreur sera attachée au champ de confirmation
});

// Type inféré à partir du schéma Zod pour être utilisé dans nos composants
export type RegisterFormValues = z.infer<typeof registerFormSchema>;
export type AlumniFormValues = z.infer<typeof alumniSchema>;
export type StudentFormValues = z.infer<typeof studentSchema>;
