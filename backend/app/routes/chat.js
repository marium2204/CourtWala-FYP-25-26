const express = require("express");
const OpenAI = require("openai");
const { PrismaClient } = require("@prisma/client");
require("dotenv").config();


const BookingService = require("../services/BookingService");
const { authenticate } = require("../middleware/AuthMiddleware.js");

const router = express.Router();
const prisma = new PrismaClient();

// OpenAI client
const client = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

/**
 * ================= PROMPT =================
 */
const SYSTEM_PROMPT = `
You are CourtWala AI, an assistant for a sports and court booking platform.

Rules:
1. You ONLY answer sports, courts, bookings, matches, and facility-related questions.
2. NEVER invent courts, bookings, or matches.
3. If real data is provided, use ONLY that data.
4. If no data exists, clearly say so.
5. Respect user privacy.
6. Keep answers short and clear.
`.trim();

/**
 * ================= INTENT DETECTION =================
 */
function detectIntent(message) {
  const msg = message.toLowerCase();

  if (msg.includes("near me") || msg.includes("nearby"))
    return "NEARBY_COURTS";

  if (msg.includes("my booking")) return "MY_BOOKINGS";
  if (msg.includes("court")) return "COURTS";
  if (msg.includes("booking")) return "BOOKINGS";
  if (msg.includes("match")) return "MATCHES";
  if (msg.includes("hi") || msg.includes("hello")) return "GREETING";

  return "GENERAL";
}

/**
 * ================= PUBLIC CHAT =================
 */
router.post("/", async (req, res) => {
  const { message, city } = req.body;

  if (!message || typeof message !== "string") {
    return res.status(400).json({ reply: "Message is required." });
  }

  try {
    const intent = detectIntent(message);

    /**
     * ========== BLOCK PRIVATE BOOKINGS ==========
     */
    if (intent === "MY_BOOKINGS") {
      return res.json({
        type: "AI",
        reply: "Please log in to view your bookings.",
      });
    }

    /**
     * ========== COURTS (DB) ==========
     */
    if (intent === "COURTS") {
      const courts = await prisma.court.findMany({
        take: 5,
        where: { status: "ACTIVE" },
      });

      return res.json({
        type: "DATA",
        reply:
          courts.length === 0
            ? "No courts available."
            : courts
                .map(
                  c => `🏟 ${c.name}
📍 ${c.location}`
                )
                .join("\n\n"),
      });
    }

    /**
     * ========== BOOKINGS (GLOBAL) ==========
     */
    if (intent === "BOOKINGS") {
      const bookings = await prisma.booking.findMany({
        take: 5,
        include: { court: true },
      });

      return res.json({
        type: "DATA",
        reply:
          bookings.length === 0
            ? "No bookings found."
            : bookings
                .map(
                  b => `🏟 ${b.court.name}
📅 ${new Date(b.date).toDateString()}
⏰ ${b.startTime} - ${b.endTime}`
                )
                .join("\n\n"),
      });
    }

    /**
     * ========== MATCHES ==========
     */
    if (intent === "MATCHES") {
      const matches = await prisma.match.findMany({ take: 5 });

      return res.json({
        type: "DATA",
        reply:
          matches.length === 0
            ? "No matches scheduled."
            : matches
                .map(
                  m => `⚔ ${m.teamA} vs ${m.teamB}
📅 ${new Date(m.date).toDateString()}`
                )
                .join("\n\n"),
      });
    }

    /**
     * ========== OPENAI FALLBACK ==========
     */
    const completion = await client.chat.completions.create({
      model: "gpt-4o-mini",
      max_completion_tokens: 200,
      messages: [
        { role: "system", content: SYSTEM_PROMPT },
        { role: "user", content: message },
      ],
    });

    return res.json({
      type: "AI",
      reply: completion.choices[0].message.content,
    });

  } catch (error) {
    console.error("Chatbot error:", error);
    return res.status(500).json({
      reply: "AI service unavailable.",
    });
  }
});

/**
 * ================= 🔐 MY BOOKINGS (AUTH ONLY) =================
 */
router.post("/my-bookings", authenticate, async (req, res) => {
  const { id, role } = req.user;

  let result;

  if (role === "PLAYER") {
    result = await BookingService.getPlayerBookings(id, {
      page: 1,
      limit: 5,
    });
  } else if (role === "OWNER") {
    result = await BookingService.getOwnerBookings(id, {
      page: 1,
      limit: 5,
    });
  } else {
    return res.json({
      type: "AI",
      reply: "Bookings are not available for this role.",
    });
  }

  const bookings = result.bookings || [];

  return res.json({
    type: "DATA",
    reply:
      bookings.length === 0
        ? role === "OWNER"
          ? "No bookings have been made on your courts yet."
          : "You have no bookings."
        : bookings
            .map(b =>
              role === "OWNER"
                ? `🏟 ${b.court.name}
👤 ${b.player.firstName} ${b.player.lastName}
📅 ${new Date(b.date).toDateString()}
⏰ ${b.startTime} - ${b.endTime}`
                : `🏟 ${b.court.name}
📅 ${new Date(b.date).toDateString()}
⏰ ${b.startTime} - ${b.endTime}`
            )
            .join("\n\n"),
  });
});

module.exports = router;
