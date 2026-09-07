"use client";

import { useEffect, useState } from "react";

interface HealthStatus {
  status: string;
  version: string;
}

export default function Home() {
  const [health, setHealth] = useState<HealthStatus | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const apiUrl = process.env.NEXT_PUBLIC_API_URL || "http://localhost:8000";

    fetch(`${apiUrl}/api/v1/health`)
      .then((res) => {
        if (!res.ok) throw new Error(`HTTP ${res.status}`);
        return res.json();
      })
      .then((data: HealthStatus) => setHealth(data))
      .catch((err: Error) => setError(err.message));
  }, []);

  return (
    <div className="flex flex-col flex-1 items-center justify-center font-sans">
      <main className="flex flex-1 w-full max-w-2xl flex-col items-center justify-center gap-8 px-8 py-16">
        {/* Project Title */}
        <div className="text-center">
          <h1 className="text-3xl font-bold tracking-tight text-foreground sm:text-4xl">
            AI Landslide Early Warning Platform
          </h1>
          <p className="mt-3 text-lg text-muted-foreground">
            SIH&apos;26 — Multi-source landslide intelligence and risk
            assessment
          </p>
        </div>

        {/* Backend Health Check */}
        <div className="w-full max-w-md rounded-lg border bg-card p-6 shadow-sm">
          <h2 className="mb-4 text-sm font-semibold uppercase tracking-wider text-muted-foreground">
            Backend Status
          </h2>

          {health ? (
            <div className="flex items-center gap-3">
              <span className="inline-block h-3 w-3 rounded-full bg-green-500" />
              <div>
                <p className="font-medium text-foreground">
                  {health.status.charAt(0).toUpperCase() +
                    health.status.slice(1)}
                </p>
                <p className="text-sm text-muted-foreground">
                  API v{health.version}
                </p>
              </div>
            </div>
          ) : error ? (
            <div className="flex items-center gap-3">
              <span className="inline-block h-3 w-3 rounded-full bg-red-500" />
              <div>
                <p className="font-medium text-foreground">Unreachable</p>
                <p className="text-sm text-muted-foreground">{error}</p>
              </div>
            </div>
          ) : (
            <div className="flex items-center gap-3">
              <span className="inline-block h-3 w-3 animate-pulse rounded-full bg-yellow-500" />
              <p className="text-sm text-muted-foreground">
                Checking backend...
              </p>
            </div>
          )}
        </div>

        {/* Architecture Note */}
        <p className="text-center text-sm text-muted-foreground">
          Detect → Verify → Predict → Explain → Prioritize → Warn
        </p>
      </main>
    </div>
  );
}
