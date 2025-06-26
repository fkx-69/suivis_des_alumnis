import { api } from "./axios";
import { ApiEvent } from "@/types/evenement";

export const fetchAllEvents = async (): Promise<ApiEvent[]> => {
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

type EventPayload = Omit<ApiEvent, "id" | "is_owner" | "valide" | "date_debut_affiche" | "date_fin_affiche">;

export const createEvent = async (data: Partial<EventPayload>): Promise<ApiEvent> => {
    const res = await api.post<ApiEvent>("/events/evenements/creer/", data);
    return res.data;
}

export const updateEvent = async (id: number, data: Partial<EventPayload>): Promise<ApiEvent> => {
    const res = await api.put<ApiEvent>(`/events/evenements/${id}/modifier/`, data);
    return res.data;
}

export const deleteEvent = async (id: number): Promise<void> => {
    await api.delete(`/events/evenements/${id}/supprimer/`);
}
