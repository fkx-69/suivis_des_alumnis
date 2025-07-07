
import UserSearch from "@/components/home/UserSearch";
import ProfileSuggestions from "@/components/home/ProfileSuggestions";
import PublicationsFeed from "@/components/home/PublicationsFeed";
import UpcomingEvents from "@/components/home/UpcomingEvents";

export default function Home() {
  return (
    <div className="mx-auto max-w-7xl px-4 py-8 space-y-8">
      <div className="flex flex-col items-center gap-4">
        <h1 className="text-3xl font-bold">Bienvenue sur la plateforme</h1>
        <UserSearch />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        {/* Suggestions */}
        <div className="space-y-8 order-2 lg:order-1">
          <ProfileSuggestions />
        </div>

        {/* Publications Feed */}
        <div className="order-1 lg:order-2">
          <PublicationsFeed />
        </div>

        {/* Upcoming Events */}
        <div className="space-y-8 order-3">
          <UpcomingEvents />
        </div>
      </div>
    </div>
  );
}
