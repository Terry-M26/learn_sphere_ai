/**
 * Firebase Cloud Function to proxy OpenAI API requests.
 * This keeps the API key secure on the server side.
 */

import {onCall, HttpsError} from "firebase-functions/v2/https";
import {setGlobalOptions} from "firebase-functions/v2";
import {defineSecret} from "firebase-functions/params";
import * as logger from "firebase-functions/logger";

// Define the secret for OpenAI API key
const openaiApiKey = defineSecret("OPENAI_API_KEY");

// Set global options for all functions
setGlobalOptions({maxInstances: 10});

// Interface for the request payload
interface ChatRequest {
  model: string;
  messages: Array<{role: string; content: string}>;
  max_tokens?: number;
  temperature?: number;
}

/**
 * Cloud Function that proxies requests to OpenAI API.
 * Allows both authenticated and guest users.
 */
export const openaiProxy = onCall(
  {secrets: [openaiApiKey]},
  async (request) => {
    const {payload} = request.data as {payload: ChatRequest};

    if (!payload || !payload.messages) {
      throw new HttpsError(
        "invalid-argument",
        "Missing required payload with messages."
      );
    }

    // Log user info (authenticated or guest)
    const userId = request.auth?.uid || "guest";
    logger.info("OpenAI proxy request from:", userId);

    try {
      const response = await fetch(
        "https://api.openai.com/v1/chat/completions",
        {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "Authorization": `Bearer ${openaiApiKey.value()}`,
          },
          body: JSON.stringify(payload),
        }
      );

      if (!response.ok) {
        const errorData = await response.json();
        logger.error("OpenAI API error:", errorData);
        throw new HttpsError(
          "internal",
          errorData.error?.message || "OpenAI API request failed"
        );
      }

      const data = await response.json();
      return data;
    } catch (error) {
      logger.error("OpenAI proxy error:", error);
      if (error instanceof HttpsError) {
        throw error;
      }
      throw new HttpsError("internal", "Failed to process request");
    }
  }
);
