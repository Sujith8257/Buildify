"use client";

import { Check, Sparkles, Zap, Users } from "lucide-react";

import { cn } from "@/lib/utils";
import { BorderBeam } from "@/components/ui/border-beam";
import { ShimmerButton } from "@/components/ui/shimmer-button";

const tiers = [
  {
    name: "Free",
    price: "$0",
    period: "forever",
    description: "Everything you need to run AI & backends on your phone.",
    icon: Zap,
    cta: "Download APK",
    ctaHref: "/#waitlist",
    highlight: false,
    features: [
      "Run LLMs & backends locally",
      "Local Wi-Fi API (192.168.x.x:8080)",
      "OpenAI-compatible endpoints",
      "API key auth + safety guards",
      "Cloudflare Tunnel (random URL)",
      "Community support (GitHub)",
      "Unlimited local requests",
      "MIT-licensed app",
    ],
  },
  {
    name: "Pro",
    price: "$3",
    period: "/month",
    description: "Your brand. Your subdomain. Your always-on server.",
    icon: Sparkles,
    cta: "Start Pro Trial",
    ctaHref: "/#waitlist",
    highlight: true,
    badge: "Most Popular",
    features: [
      "Everything in Free, plus:",
      "Custom subdomain (you.buildify.me)",
      "Persistent tunnel (no rotation)",
      "Web dashboard & analytics",
      "Request logs & latency graphs",
      "Priority model downloads",
      "Email support",
      "Pro badge in community",
    ],
  },
  {
    name: "Team",
    price: "$15",
    period: "/month",
    description: "For teams and power users who need serious infrastructure.",
    icon: Users,
    cta: "Contact Us",
    ctaHref: "mailto:team@buildify.me",
    highlight: false,
    badge: "Coming Soon",
    features: [
      "Everything in Pro, plus:",
      "Multiple devices, one account",
      "Team API key management",
      "Load balancing across devices",
      "Webhook notifications",
      "Custom domain support",
      "SLA + dedicated support",
      "Early access to new features",
    ],
  },
];

export function Pricing() {
  return (
    <section
      id="pricing"
      className="relative mx-auto max-w-7xl px-4 py-24 sm:px-6 lg:px-8"
    >
      <div className="mx-auto max-w-2xl text-center">
        <span className="inline-flex items-center rounded-full border border-white/10 bg-white/[0.03] px-3 py-1 text-xs font-medium uppercase tracking-wider text-muted-foreground">
          Pricing
        </span>
        <h2 className="mt-4 text-balance text-3xl font-bold tracking-tight sm:text-4xl">
          Free to start.{" "}
          <span className="text-brand-gradient">Pro when you're ready.</span>
        </h2>
        <p className="mt-4 text-balance text-muted-foreground">
          The app is open-source and free forever. Upgrade for custom
          subdomains, analytics, and a dashboard that makes your phone feel like
          a cloud.
        </p>
      </div>

      <div className="mx-auto mt-12 grid max-w-6xl gap-6 lg:grid-cols-3">
        {tiers.map((tier) => (
          <PricingCard key={tier.name} tier={tier} />
        ))}
      </div>

      <p className="mt-8 text-center text-xs text-muted-foreground">
        All plans include the MIT-licensed open-source app. Cloud features
        require a Buildify account.
      </p>
    </section>
  );
}

function PricingCard({
  tier,
}: {
  tier: (typeof tiers)[number];
}) {
  const Icon = tier.icon;
  return (
    <div
      className={cn(
        "relative flex flex-col rounded-2xl border p-6 backdrop-blur-sm transition-all sm:p-8",
        tier.highlight
          ? "border-[oklch(0.82_0.16_195)]/30 bg-[oklch(0.82_0.16_195)]/[0.04] shadow-[0_0_60px_-10px_oklch(0.82_0.16_195/0.2)]"
          : "border-white/10 bg-card/40"
      )}
    >
      {tier.highlight && (
        <BorderBeam
          size={180}
          duration={10}
          colorFrom="oklch(0.82 0.16 195)"
          colorTo="oklch(0.7 0.2 290)"
        />
      )}

      <div className="flex items-center justify-between">
        <div className="flex items-center gap-2">
          <div
            className={cn(
              "flex h-9 w-9 items-center justify-center rounded-lg",
              tier.highlight
                ? "bg-[oklch(0.82_0.16_195)]/15 text-[oklch(0.82_0.16_195)]"
                : "bg-white/[0.04] text-muted-foreground"
            )}
          >
            <Icon className="h-4 w-4" />
          </div>
          <h3 className="text-lg font-semibold text-foreground">{tier.name}</h3>
        </div>
        {tier.badge && (
          <span
            className={cn(
              "rounded-full px-2.5 py-0.5 text-[10px] font-medium uppercase tracking-wider",
              tier.highlight
                ? "bg-[oklch(0.82_0.16_195)]/15 text-[oklch(0.82_0.16_195)]"
                : "bg-white/[0.04] text-muted-foreground"
            )}
          >
            {tier.badge}
          </span>
        )}
      </div>

      <div className="mt-4">
        <span className="text-4xl font-bold tracking-tight text-foreground">
          {tier.price}
        </span>
        <span className="ml-1 text-sm text-muted-foreground">
          {tier.period}
        </span>
      </div>

      <p className="mt-2 text-sm text-muted-foreground">{tier.description}</p>

      <ul className="mt-6 flex-1 space-y-2.5">
        {tier.features.map((feature, i) => (
          <li key={i} className="flex items-start gap-2.5 text-sm">
            <Check
              className={cn(
                "mt-0.5 h-4 w-4 shrink-0",
                i === 0 && !tier.highlight
                  ? "text-muted-foreground"
                  : "text-[oklch(0.82_0.16_195)]"
              )}
            />
            <span
              className={cn(
                i === 0 && tier.name !== "Free"
                  ? "font-medium text-foreground"
                  : "text-muted-foreground"
              )}
            >
              {feature}
            </span>
          </li>
        ))}
      </ul>

      <div className="mt-8">
        {tier.highlight ? (
          <a href={tier.ctaHref}>
            <ShimmerButton
              className="w-full shadow-2xl"
              shimmerColor="#9adfff"
              background="oklch(0.11 0.015 260)"
            >
              <span className="flex items-center justify-center gap-2 text-sm font-medium text-foreground">
                {tier.cta}
                <Sparkles className="h-3.5 w-3.5" />
              </span>
            </ShimmerButton>
          </a>
        ) : (
          <a
            href={tier.ctaHref}
            className={cn(
              "flex h-11 w-full items-center justify-center rounded-lg border text-sm font-medium transition-colors",
              "border-white/10 bg-white/[0.03] text-foreground hover:bg-white/[0.06]"
            )}
          >
            {tier.cta}
          </a>
        )}
      </div>
    </div>
  );
}
