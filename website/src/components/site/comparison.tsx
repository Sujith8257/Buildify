"use client";

import { Check, Minus, X } from "lucide-react";

import { cn } from "@/lib/utils";

type CellValue = true | false | string;

const categories = [
  {
    name: "Monthly cost",
    buildify: "$0 – $5",
    ollama: "$0",
    openai: "$20+",
    cloudVm: "$5 – $50+",
  },
  {
    name: "Runs on a phone",
    buildify: true,
    ollama: false,
    openai: false,
    cloudVm: false,
  },
  {
    name: "Data stays on device",
    buildify: true,
    ollama: true,
    openai: false,
    cloudVm: false,
  },
  {
    name: "Setup time",
    buildify: "< 5 min",
    ollama: "10 min",
    openai: "2 min",
    cloudVm: "30+ min",
  },
  {
    name: "Custom subdomain",
    buildify: true,
    ollama: false,
    openai: false,
    cloudVm: "DIY",
  },
  {
    name: "OpenAI-compatible API",
    buildify: true,
    ollama: true,
    openai: true,
    cloudVm: "DIY",
  },
  {
    name: "No cloud account needed",
    buildify: true,
    ollama: true,
    openai: false,
    cloudVm: false,
  },
  {
    name: "Open source",
    buildify: true,
    ollama: true,
    openai: false,
    cloudVm: "Varies",
  },
  {
    name: "Public tunnel built-in",
    buildify: true,
    ollama: false,
    openai: true,
    cloudVm: "DIY",
  },
  {
    name: "Mobile-first UX",
    buildify: true,
    ollama: false,
    openai: false,
    cloudVm: false,
  },
];

const competitors = [
  { key: "buildify" as const, name: "Buildify", highlight: true },
  { key: "ollama" as const, name: "Ollama", highlight: false },
  { key: "openai" as const, name: "OpenAI API", highlight: false },
  { key: "cloudVm" as const, name: "Cloud VM", highlight: false },
];

export function Comparison() {
  return (
    <section
      id="comparison"
      className="relative mx-auto max-w-7xl px-4 py-24 sm:px-6 lg:px-8"
    >
      <div className="mx-auto max-w-2xl text-center">
        <span className="inline-flex items-center rounded-full border border-white/10 bg-white/[0.03] px-3 py-1 text-xs font-medium uppercase tracking-wider text-muted-foreground">
          Compare
        </span>
        <h2 className="mt-4 text-balance text-3xl font-bold tracking-tight sm:text-4xl">
          See how Buildify{" "}
          <span className="text-brand-gradient">stacks up.</span>
        </h2>
        <p className="mt-4 text-balance text-muted-foreground">
          No hidden costs, no cloud lock-in, no laptop required.
        </p>
      </div>

      {/* Desktop Table */}
      <div className="mx-auto mt-12 hidden max-w-5xl overflow-hidden rounded-2xl border border-white/10 bg-card/40 backdrop-blur-sm md:block">
        <table className="w-full text-sm">
          <thead>
            <tr className="border-b border-white/5">
              <th className="p-4 text-left text-xs font-medium uppercase tracking-wider text-muted-foreground">
                Feature
              </th>
              {competitors.map((c) => (
                <th
                  key={c.key}
                  className={cn(
                    "p-4 text-center text-xs font-medium uppercase tracking-wider",
                    c.highlight
                      ? "bg-[oklch(0.82_0.16_195)]/[0.06] text-[oklch(0.82_0.16_195)]"
                      : "text-muted-foreground"
                  )}
                >
                  {c.name}
                </th>
              ))}
            </tr>
          </thead>
          <tbody>
            {categories.map((cat, i) => (
              <tr
                key={cat.name}
                className={cn(
                  "border-b border-white/5 transition-colors hover:bg-white/[0.02]",
                  i === categories.length - 1 && "border-b-0"
                )}
              >
                <td className="p-4 text-sm font-medium text-foreground">
                  {cat.name}
                </td>
                {competitors.map((c) => (
                  <td
                    key={c.key}
                    className={cn(
                      "p-4 text-center",
                      c.highlight && "bg-[oklch(0.82_0.16_195)]/[0.03]"
                    )}
                  >
                    <CellDisplay
                      value={cat[c.key] as CellValue}
                      highlight={c.highlight}
                    />
                  </td>
                ))}
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {/* Mobile Cards */}
      <div className="mx-auto mt-12 space-y-4 md:hidden">
        {categories.map((cat) => (
          <div
            key={cat.name}
            className="rounded-xl border border-white/10 bg-card/40 p-4 backdrop-blur-sm"
          >
            <p className="mb-3 text-sm font-medium text-foreground">
              {cat.name}
            </p>
            <div className="grid grid-cols-2 gap-2">
              {competitors.map((c) => (
                <div
                  key={c.key}
                  className={cn(
                    "flex items-center justify-between rounded-lg border px-3 py-2 text-xs",
                    c.highlight
                      ? "border-[oklch(0.82_0.16_195)]/20 bg-[oklch(0.82_0.16_195)]/[0.06]"
                      : "border-white/5 bg-white/[0.02]"
                  )}
                >
                  <span className="text-muted-foreground">{c.name}</span>
                  <CellDisplay
                    value={cat[c.key] as CellValue}
                    highlight={c.highlight}
                  />
                </div>
              ))}
            </div>
          </div>
        ))}
      </div>
    </section>
  );
}

function CellDisplay({
  value,
  highlight,
}: {
  value: CellValue;
  highlight: boolean;
}) {
  if (value === true) {
    return (
      <span className="inline-flex items-center justify-center">
        <Check
          className={cn(
            "h-4 w-4",
            highlight
              ? "text-[oklch(0.82_0.16_195)]"
              : "text-[oklch(0.85_0.18_145)]"
          )}
        />
      </span>
    );
  }
  if (value === false) {
    return (
      <span className="inline-flex items-center justify-center">
        <X className="h-4 w-4 text-muted-foreground/40" />
      </span>
    );
  }
  return (
    <span
      className={cn(
        "text-xs font-medium",
        highlight ? "text-foreground" : "text-muted-foreground"
      )}
    >
      {value}
    </span>
  );
}
