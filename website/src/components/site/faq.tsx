"use client";

import {
  Accordion,
  AccordionContent,
  AccordionItem,
  AccordionTrigger,
} from "@/components/ui/accordion";

const faqs = [
  {
    q: "What's the difference between Free and Pro?",
    a: "The core app and local Wi-Fi hosting (e.g. 192.168.1.5:8080) are completely free and open-source forever. Buildify Pro ($3/mo) gives you a persistent custom subdomain (you.buildify.me), a web dashboard to track requests and latency, and priority model downloads. Pro turns your phone into a true cloud endpoint.",
  },
  {
    q: "How does the custom subdomain (buildify.me) work?",
    a: "When you upgrade to Pro, the app provisions a persistent Cloudflare Tunnel bound to your account. Instead of a random trycloudflare.com URL that changes every time you restart the app, you get a stable, branded URL that you can hardcode into your frontend apps or scripts.",
  },
  {
    q: "Can I host non-AI backends too?",
    a: "Not yet, but it's on our immediate roadmap! We are currently focused on providing the best local LLM experience with llama-server. Soon, we'll add support to run custom Node.js (Express) and Python (Flask/FastAPI) servers directly from the app.",
  },
  {
    q: "Is it really free?",
    a: "The base app is 100% free. The app is MIT-licensed, the engine (llama.cpp) is MIT, and the models are open weights. The only thing you pay is electricity. You only pay us if you want the premium cloud routing features (Pro).",
  },
  {
    q: "Will it kill my battery?",
    a: "Sustained inference is hot work. Buildify has auto-stop guards out of the box: idle timeout, low-battery cutoff, and thermal severity. You can tune each from the Home screen to protect your device.",
  },
  {
    q: "Is the code open?",
    a: "Yes! Buildify follows an Open Core model. The Android app and inference bridge are on GitHub and MIT-licensed. The backend infrastructure that powers the Pro features (tunnels, dashboard) is proprietary SaaS.",
  },
  {
    q: "Which phones can handle this?",
    a: "Any modern arm64-v8a Android phone. TinyLlama 1.1B and Qwen2 1.5B run on phones with 4 GB RAM. Phi-3 Mini 3.8B is comfortable on 6 GB+. Expect 10–25 tokens/sec on a Snapdragon 8 Gen 1 or newer.",
  },
];

export function Faq() {
  return (
    <section
      id="faq"
      className="relative mx-auto max-w-3xl px-4 py-24 sm:px-6 lg:px-8"
    >
      <div className="mx-auto max-w-2xl text-center">
        <span className="inline-flex items-center rounded-full border border-white/10 bg-white/[0.03] px-3 py-1 text-xs font-medium uppercase tracking-wider text-muted-foreground">
          FAQ
        </span>
        <h2 className="mt-4 text-balance text-3xl font-bold tracking-tight sm:text-4xl">
          Frequently asked questions
        </h2>
      </div>

      <Accordion className="mt-12 w-full">
        {faqs.map((faq, i) => (
          <AccordionItem
            key={i}
            value={`item-${i}`}
            className="border-white/5"
          >
            <AccordionTrigger className="text-left text-base font-medium text-foreground hover:no-underline">
              {faq.q}
            </AccordionTrigger>
            <AccordionContent className="text-muted-foreground">
              {faq.a}
            </AccordionContent>
          </AccordionItem>
        ))}
      </Accordion>
    </section>
  );
}
