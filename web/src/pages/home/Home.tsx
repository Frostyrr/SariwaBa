import React from "react";
import { Hero } from "./sections/Hero";
import { Features } from "./sections/Features";
import { HowItWorks } from "./sections/HowItWorks";
import { History } from "./sections/History";
import { CommunityCTA } from "./sections/CommunityCTA";

export const Home: React.FC = () => {
  return (
    <main className="flex-1 flex flex-col w-full">
      <Hero />
      <History />
      <Features />
      <HowItWorks />
      <CommunityCTA />
    </main>
  );
};

export default Home;
