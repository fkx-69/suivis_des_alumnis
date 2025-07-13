import ConfirmModal from "./ConfirmModal";

interface DeleteConfirmModalProps {
  title: string;
  message: string;
  onDelete: () => void;
  onCancel?: () => void;
}

export default function DeleteConfirmModal({
  title,
  message,
  onDelete,
  onCancel,
}: DeleteConfirmModalProps) {
  return (
    <ConfirmModal
      title={title}
      message={message}
      confirmText="Supprimer"
      cancelText="Annuler"
      onConfirm={onDelete}
      onCancel={onCancel ?? (() => {})}
    />
  );
}
