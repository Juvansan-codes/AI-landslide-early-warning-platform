"use client";

import { useEffect, useState } from "react";
import { apiGet } from "@/lib/api";
import { Database, Server, Activity, DatabaseZap } from "lucide-react";

interface DatabaseStats {
  total_risk_cells: number;
  total_sensors: number;
}

interface DatabaseStatus {
  status: string;
  message: string;
  stats: DatabaseStats | null;
}

interface SystemStatus {
  api_status: string;
  version: string;
  database: DatabaseStatus;
}

export default function Home() {
  const [system, setSystem] = useState<SystemStatus | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    apiGet<SystemStatus>("/api/v1/system/status")
      .then((data) => setSystem(data))
      .catch((err: Error) => setError(err.message));
  }, []);

  return (
    <div className="flex flex-col flex-1 items-center justify-center font-sans min-h-screen bg-background">
      <main className="flex flex-1 w-full max-w-4xl flex-col items-center justify-center gap-12 px-8 py-16">
        {/* Project Title */}
        <div className="text-center space-y-4">
          <div className="inline-flex items-center justify-center p-3 bg-primary/10 rounded-full mb-4">
            <Activity className="w-8 h-8 text-primary" />
          </div>
          <h1 className="text-4xl md:text-5xl font-bold tracking-tight text-foreground">
            AI Landslide Early Warning
          </h1>
          <p className="text-xl text-muted-foreground max-w-2xl mx-auto">
            SIH&apos;26 — Multi-source landslide intelligence and risk assessment platform
          </p>
        </div>

        {/* System Status Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6 w-full max-w-3xl">
          
          {/* API Status Card */}
          <div className="rounded-xl border bg-card p-6 shadow-sm flex flex-col gap-4">
            <div className="flex items-center gap-3">
              <Server className="w-5 h-5 text-muted-foreground" />
              <h2 className="text-sm font-semibold uppercase tracking-wider text-muted-foreground">
                API Backend
              </h2>
            </div>
            
            {system ? (
              <div className="flex items-center gap-3 mt-2">
                <span className="relative flex h-4 w-4">
                  <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-green-400 opacity-75"></span>
                  <span className="relative inline-flex rounded-full h-4 w-4 bg-green-500"></span>
                </span>
                <div>
                  <p className="font-medium text-lg text-foreground">
                    Operational
                  </p>
                  <p className="text-sm text-muted-foreground">
                    Version {system.version}
                  </p>
                </div>
              </div>
            ) : error ? (
              <div className="flex items-center gap-3 mt-2">
                <span className="inline-block h-4 w-4 rounded-full bg-red-500" />
                <div>
                  <p className="font-medium text-lg text-foreground">Unreachable</p>
                  <p className="text-sm text-muted-foreground truncate max-w-[200px]" title={error}>
                    {error}
                  </p>
                </div>
              </div>
            ) : (
              <div className="flex items-center gap-3 mt-2">
                <span className="inline-block h-4 w-4 animate-pulse rounded-full bg-yellow-500" />
                <p className="text-sm text-muted-foreground">Connecting...</p>
              </div>
            )}
          </div>

          {/* Database Status Card */}
          <div className="rounded-xl border bg-card p-6 shadow-sm flex flex-col gap-4">
            <div className="flex items-center gap-3">
              <Database className="w-5 h-5 text-muted-foreground" />
              <h2 className="text-sm font-semibold uppercase tracking-wider text-muted-foreground">
                Supabase Database
              </h2>
            </div>

            {system ? (
              <div className="flex items-center gap-3 mt-2">
                <span className={`relative flex h-4 w-4`}>
                  {system.database.status === "connected" && (
                     <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-green-400 opacity-75"></span>
                  )}
                  <span className={`relative inline-flex rounded-full h-4 w-4 ${
                    system.database.status === "connected" ? "bg-green-500" : 
                    system.database.status === "not_configured" ? "bg-yellow-500" : "bg-red-500"
                  }`}></span>
                </span>
                <div>
                  <p className="font-medium text-lg text-foreground">
                    {system.database.status === "connected" ? "Connected" : 
                     system.database.status === "not_configured" ? "Not Configured" : "Connection Error"}
                  </p>
                  <p className="text-sm text-muted-foreground truncate max-w-[200px]" title={system.database.message}>
                    {system.database.message}
                  </p>
                </div>
              </div>
            ) : error ? (
              <div className="flex items-center gap-3 mt-2">
                <span className="inline-block h-4 w-4 rounded-full bg-muted" />
                <div>
                  <p className="font-medium text-lg text-foreground text-muted-foreground">Unknown</p>
                  <p className="text-sm text-muted-foreground">Waiting for API...</p>
                </div>
              </div>
            ) : (
              <div className="flex items-center gap-3 mt-2">
                <span className="inline-block h-4 w-4 animate-pulse rounded-full bg-yellow-500" />
                <p className="text-sm text-muted-foreground">Checking...</p>
              </div>
            )}
          </div>
        </div>

        {/* Database Stats (Only visible when connected) */}
        {system?.database?.stats && (
          <div className="w-full max-w-3xl rounded-xl border bg-card p-6 shadow-sm animate-in fade-in slide-in-from-bottom-4 duration-500">
            <div className="flex items-center gap-3 mb-6">
              <DatabaseZap className="w-5 h-5 text-primary" />
              <h2 className="text-sm font-semibold uppercase tracking-wider text-foreground">
                Live Data Statistics
              </h2>
            </div>
            
            <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
              <div className="flex flex-col p-4 bg-muted/50 rounded-lg">
                <span className="text-3xl font-bold text-foreground">{system.database.stats.total_risk_cells}</span>
                <span className="text-sm text-muted-foreground mt-1">Risk Cells</span>
              </div>
              <div className="flex flex-col p-4 bg-muted/50 rounded-lg">
                <span className="text-3xl font-bold text-foreground">{system.database.stats.total_sensors}</span>
                <span className="text-sm text-muted-foreground mt-1">IoT Sensors</span>
              </div>
              <div className="flex flex-col p-4 bg-muted/50 rounded-lg opacity-50">
                <span className="text-3xl font-bold text-foreground">0</span>
                <span className="text-sm text-muted-foreground mt-1">Active Alerts</span>
              </div>
              <div className="flex flex-col p-4 bg-muted/50 rounded-lg opacity-50">
                <span className="text-3xl font-bold text-foreground">0</span>
                <span className="text-sm text-muted-foreground mt-1">Reports</span>
              </div>
            </div>
          </div>
        )}

        {/* Architecture Note */}
        <div className="mt-8 pt-8 border-t border-border w-full max-w-3xl text-center">
          <p className="text-sm font-medium tracking-widest uppercase text-muted-foreground flex items-center justify-center gap-2 flex-wrap">
            <span>Detect</span> <span className="text-primary/40">→</span>
            <span>Verify</span> <span className="text-primary/40">→</span>
            <span>Predict</span> <span className="text-primary/40">→</span>
            <span>Explain</span> <span className="text-primary/40">→</span>
            <span>Prioritize</span> <span className="text-primary/40">→</span>
            <span>Warn</span>
          </p>
        </div>
      </main>
    </div>
  );
}
