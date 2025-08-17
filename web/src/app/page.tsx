import UserSearch from "@/components/home/UserSearch";
import ProfileSuggestions from "@/components/home/ProfileSuggestions";
import PublicationsFeed from "@/components/home/PublicationsFeed";
import UpcomingEvents from "@/components/home/UpcomingEvents";
import HeroSection from "@/components/home/HeroSection";

export default function Home() {
  return (
    <div className="container mx-auto p-4 sm:p-6 lg:p-8 space-y-12">
      <HeroSection />

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        <div className="lg:col-span-2 space-y-12">
          <UserSearch />
          <UpcomingEvents />
          <PublicationsFeed />
        </div>

        <aside className="space-y-12">
          <ProfileSuggestions />
        </aside>
      </div>
    </div>
  );
}
