import { api } from "./axios";
import { ApiEvent } from "@/types/evenement";

export const fetchEvents = async (): Promise<ApiEvent[]> => {
    const res = await api.get<ApiEvent[]>("/events/evenements/");
    if (res.status < 200 || res.status >= 300) {
        throw new Error("Impossible de récupérer les événements");
    }
    // Filtre pour ne garder que les évènements futurs
    return res.data
        .filter((e) => new Date(e.date_debut).getTime() > Date.now())
        .sort(
            (a, b) =>
                new Date(a.date_debut).getTime() - new Date(b.date_debut).getTime()
        );
};

export const fetchPendingEvents = async (): Promise<ApiEvent[]> => {
    // Le nouvel endpoint renvoie directement un tableau d'événements
    const res = await api.get<ApiEvent[]>("/events/mes-evenements-en-attente/");
    return res.data;
}

type EventUpdatePayload = Omit<ApiEvent, "id" | "is_owner" | "valide" | "date_debut_affiche" | "date_fin_affiche">;

type EventCreatePayload = {
    titre: string;
    description: string;
    date_debut: string;
    date_fin: string;
    image?: File;
}

export const createEvent = async (data: EventCreatePayload): Promise<ApiEvent> => {
    const formData = new FormData();
    formData.append('titre', data.titre);
    formData.append('description', data.description);
    formData.append('date_debut', data.date_debut);
    formData.append('date_fin', data.date_fin);
    if (data.image) {
        formData.append('image', data.image);
    }
    const res = await api.post<ApiEvent>("/events/evenements/creer/", formData, {
        headers: { 'Content-Type': 'multipart/form-data' }
    });
    return res.data;
}

export const updateEvent = async (id: number, data: Partial<EventUpdatePayload>): Promise<ApiEvent> => {
    const res = await api.put<ApiEvent>(`/events/evenements/${id}/modifier/`, data);
    return res.data;
}

export const deleteEvent = async (id: number): Promise<void> => {
    await api.delete(`/events/evenements/${id}/supprimer/`);
}
