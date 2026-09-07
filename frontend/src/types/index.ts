/**
 * Shared TypeScript type definitions.
 *
 * This barrel file exports types used across the frontend application.
 * Add new type exports here as features are implemented.
 */

/** Health check response from the backend API. */
export interface HealthResponse {
  status: string;
  version: string;
}
