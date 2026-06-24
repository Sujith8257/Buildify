"use client";

import { cn } from "@/lib/utils";
import { Marquee } from "@/components/ui/marquee";

const techStack = [
  { name: "llama.cpp", desc: "Inference engine" },
  { name: "Cloudflare", desc: "Tunnel provider" },
  { name: "Flutter", desc: "Cross-platform UI" },
  { name: "Kotlin", desc: "Native Android" },
  { name: "GGUF", desc: "Model format" },
  { name: "OpenAI API", desc: "Compatible" },
];

const testimonials = [
  {
    name: "Early Beta Tester",
    handle: "@builder",
    text: "I pointed my Continue.dev extension at my phone and got code completions. On my phone. For free. This is insane.",
    avatar: "🧑‍💻",
  },
  {
    name: "Privacy Enthusiast",
    handle: "@privsec",
    text: "Finally an AI tool where my data never leaves my device. No cloud, no third-party, no trust required. Just my phone and my model.",
    avatar: "🔒",
  },
  {
    name: "Indie Hacker",
    handle: "@indie_dev",
    text: "username.buildify.me is a genius move. I can share my AI endpoint with clients without spinning up a cloud VM. Game changer.",
    avatar: "🚀",
  },
  {
    name: "Student Developer",
    handle: "@cs_student",
    text: "Zero cloud bill. I ran a full LLM API on my old Pixel 6 for a hackathon demo. Judges were blown away.",
    avatar: "🎓",
  },
];

export function SocialProof() {
  return (
    <section className="relative mx-auto max-w-7xl px-4 py-16 sm:px-6 lg:px-8">
      {/* Built With Tech Strip */}
      <div className="mx-auto max-w-4xl">
        <p className="mb-6 text-center text-xs uppercase tracking-wider text-muted-foreground">
          Built with the best in open-source
        </p>
        <div className="grid grid-cols-3 gap-3 sm:grid-cols-6">
          {techStack.map((tech) => (
            <div
              key={tech.name}
              className="flex flex-col items-center gap-1 rounded-xl border border-white/5 bg-white/[0.02] px-3 py-3 text-center backdrop-blur-sm transition-colors hover:bg-white/[0.04]"
            >
              <span className="text-xs font-medium text-foreground">
                {tech.name}
              </span>
              <span className="text-[10px] text-muted-foreground">
                {tech.desc}
              </span>
            </div>
          ))}
        </div>
      </div>

      {/* Testimonials Marquee */}
      <div className="mt-16">
        <p className="mb-6 text-center text-xs uppercase tracking-wider text-muted-foreground">
          What builders are saying
        </p>
        <Marquee
          pauseOnHover
          className="[--duration:40s] [mask-image:linear-gradient(to_right,transparent,#000_10%,#000_90%,transparent)]"
        >
          {testimonials.map((t, i) => (
            <TestimonialCard key={i} testimonial={t} />
          ))}
        </Marquee>
      </div>

      {/* Stats Row */}
      <div className="mx-auto mt-16 grid max-w-2xl grid-cols-3 gap-4">
        <MiniStat label="Open Source" value="MIT" />
        <MiniStat label="Cloud Spend" value="$0" />
        <MiniStat label="Setup Time" value="<5min" />
      </div>
    </section>
  );
}

function TestimonialCard({
  testimonial,
}: {
  testimonial: (typeof testimonials)[number];
}) {
  return (
    <div className="mx-2 w-[300px] shrink-0 rounded-2xl border border-white/10 bg-card/40 p-5 backdrop-blur-sm">
      <div className="flex items-center gap-3">
        <div className="flex h-10 w-10 items-center justify-center rounded-full bg-white/[0.04] text-lg">
          {testimonial.avatar}
        </div>
        <div>
          <p className="text-sm font-medium text-foreground">
            {testimonial.name}
          </p>
          <p className="text-xs text-muted-foreground">{testimonial.handle}</p>
        </div>
      </div>
      <p className="mt-3 text-sm leading-relaxed text-muted-foreground">
        &ldquo;{testimonial.text}&rdquo;
      </p>
    </div>
  );
}

function MiniStat({ label, value }: { label: string; value: string }) {
  return (
    <div className="rounded-xl border border-white/5 bg-white/[0.02] p-4 text-center backdrop-blur-sm">
      <div className="font-mono text-xl font-bold tracking-tight text-foreground sm:text-2xl">
        {value}
      </div>
      <div className="mt-1 text-[10px] uppercase tracking-wider text-muted-foreground">
        {label}
      </div>
    </div>
  );
}
