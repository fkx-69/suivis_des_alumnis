import UserSearch from "@/components/home/UserSearch";
import ProfileSuggestions from "@/components/home/ProfileSuggestions";
import PublicationsFeed from "@/components/home/PublicationsFeed";
import UpcomingEvents from "@/components/home/UpcomingEvents";

export default function Home() {
  return (
    <div className="container mx-auto p-4 sm:p-6 lg:p-8 space-y-12">
      <div className="mb-4">
        <UserSearch />
      </div>

      <section>
        <UpcomingEvents />
      </section>

      <section>
        <PublicationsFeed />
      </section>

      <section className="max-w-md mx-auto">
        <ProfileSuggestions />
      </section>
    </div>
  );
}
