import React from 'react';
import { Hero } from './sections/Hero';
import { Features } from './sections/Features';
import { HowItWorks } from './sections/HowItWorks';
import { History } from './sections/History';

export const Home: React.FC = () => {
  return (
    <main className="flex-1 flex flex-col w-full">
      <Hero />
      <Features />
      <HowItWorks />
      <History />
    </main>
  );
};

export default Home;



