/* app/(dashboard)/evenements/page.tsx */
"use client";

import { useEffect, useState } from "react";
import { Plus } from "lucide-react";

import AddEventModal from "@/components/AddEventModal";
import EventCard from "@/components/EventCard";
import EventModal from "@/components/EventModal";
import DeleteConfirmModal from "@/components/DeleteConfirmModal";
import { ApiEvent } from "@/types/evenement";

import {
  fetchEvents, // tous les événements validés
  fetchPendingEvents, // événements en attente de validation pour l’utilisateur
  deleteEvent,
} from "@/lib/api/evenement";

type Tab = "all" | "pending";
export default function EventsPage() {
  const [tab, setTab] = useState<Tab>("all");
  const [events, setEvents] = useState<ApiEvent[]>([]);
  const [pendingEvents, setPendingEvents] = useState<ApiEvent[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [showForm, setShowForm] = useState(false);
  const [editing, setEditing] = useState<ApiEvent | null>(null);
  const [selected, setSelected] = useState<ApiEvent | null>(null);
  const [toDelete, setToDelete] = useState<ApiEvent | null>(null);

  // Chargement initial des événements validés
  useEffect(() => {
    (async () => {
      setLoading(true);
      try {
        setEvents(await fetchEvents());
      } catch (e) {
        setError(e instanceof Error ? e.message : "Erreur inconnue");
      } finally {
        setLoading(false);
      }
    })();
  }, []);

  // Chargement des en attente à chaque bascule sur tab="pending"
  useEffect(() => {
    if (tab !== "pending") return;
    (async () => {
      setLoading(true);
      try {
        setPendingEvents(await fetchPendingEvents());
      } catch (e) {
        setError(e instanceof Error ? e.message : "Erreur inconnue");
      } finally {
        setLoading(false);
      }
    })();
  }, [tab]);

  // Création
  const handleCreated = (ev: ApiEvent) => {
    if (ev.valide) {
      setEvents((prev) => [...prev, ev]);
      setTab("all");
    } else {
      setPendingEvents((prev) => [...prev, ev]);
      setTab("pending");
    }
    setShowForm(false);
  };

  // Mise à jour
  const handleUpdated = (ev: ApiEvent) => {
    const patch = (arr: ApiEvent[]) =>
      arr.map((e) => (e.id === ev.id ? ev : e));
    if (ev.valide) {
      setEvents(patch);
      setPendingEvents((prev) => prev.filter((e) => e.id !== ev.id));
    } else {
      setPendingEvents(patch);
      setEvents((prev) => prev.filter((e) => e.id !== ev.id));
    }
    setEditing(null);
  };

  // Suppression
  const confirmDelete = async () => {
    if (!toDelete) return;
    try {
      await deleteEvent(toDelete.id);
      setEvents((prev) => prev.filter((e) => e.id !== toDelete.id));
      setPendingEvents((prev) => prev.filter((e) => e.id !== toDelete.id));
    } finally {
      setToDelete(null);
    }
  };

  // Choix de la liste à afficher
  const list = tab === "pending" ? pendingEvents : events;

  if (loading) {
    return (
      <div className="flex justify-center mt-10">
        <span className="loading loading-spinner loading-lg" />
      </div>
    );
  }

  if (error) {
    return (
      <div className="alert alert-error max-w-lg mx-auto mt-10">
        <span>{error}</span>
      </div>
    );
  }

  return (
    <main className="mx-auto max-w-7xl px-4 py-4 lg:py-8">
      {/* Onglets */}
      <div className="mb-6 flex gap-2">
        <button
          className={`btn btn-primary ${tab === "all" ? "btn-active" : "btn-soft"}`}
          onClick={() => setTab("all")}
        >
          Tous les événements
        </button>
        <button
          className={`btn btn-primary ${tab === "pending" ? "btn-active" : "btn-soft"}`}
          onClick={() => {
            setLoading(true);
            setTab("pending");
          }}
        >
          En attente
        </button>
      </div>

      {/* Modales création / édition */}
      {showForm && (
        <AddEventModal
          onCreated={handleCreated}
          onClose={() => setShowForm(false)}
        />
      )}
      {editing && (
        <AddEventModal
          event={editing}
          onUpdated={handleUpdated}
          onClose={() => setEditing(null)}
        />
      )}

      {/* Liste */}
      {list.length === 0 ? (
        <div className="alert alert-info max-w-lg mx-auto mt-10">
          <span>
            {tab === "pending"
              ? "Aucun événement en attente."
              : "Aucun événement à afficher."}
          </span>
        </div>
      ) : (
        <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
          {list.map((ev) => (
            <EventCard
              key={ev.id}
              event={ev}
              onToggle={() => setSelected(ev)}
              showActions={tab === "pending"}
              onEdit={() => setEditing(ev)}
              onDelete={() => setToDelete(ev)}
            />
          ))}
        </div>
      )}

      {/* Détails & suppression */}
      {selected && (
        <EventModal event={selected} onClose={() => setSelected(null)} />
      )}
      {toDelete && (
        <DeleteConfirmModal
          title="Supprimer l'événement"
          message={`Supprimer « ${toDelete.titre} » ?`}
          onDelete={confirmDelete}
          onCancel={() => setToDelete(null)}
        />
      )}

      {/* Bouton Ajouter */}
      <button
        onClick={() => setShowForm(true)}
        className="btn btn-primary btn-circle fixed bottom-10 right-10 shadow-lg z-50"
        aria-label="Ajouter un événement"
      >
        <Plus size={28} />
      </button>
    </main>
  );
}
