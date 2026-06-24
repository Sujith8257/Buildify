import { Hero } from "@/components/site/hero";
import { SocialProof } from "@/components/site/social-proof";
import { Features } from "@/components/site/features";
import { HowItWorks } from "@/components/site/how-it-works";
import { LiveDemo } from "@/components/site/live-demo";
import { Comparison } from "@/components/site/comparison";
import { Pricing } from "@/components/site/pricing";
import { Faq } from "@/components/site/faq";
import { Waitlist } from "@/components/site/waitlist";

export default function HomePage() {
  return (
    <>
      <Hero />
      <SocialProof />
      <Features />
      <HowItWorks />
      <LiveDemo />
      <Comparison />
      <Pricing />
      <Faq />
      <Waitlist />
    </>
  );
}
