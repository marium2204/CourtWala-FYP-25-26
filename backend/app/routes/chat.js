const express = require("express");
const OpenAI = require("openai");
const { PrismaClient } = require("@prisma/client");
require("dotenv").config();

const router = express.Router();
const prisma = new PrismaClient();

const client = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

/**
 * ================= PROMPT =================
 */
const AI_PROMPT = `
You are CourtWala AI, a domain-restricted assistant.

DOMAIN RULES (VERY IMPORTANT):
1. You are ONLY allowed to answer questions related to:
   - Sports (rules, meanings, scoring, gameplay)
   - Courts and sports facilities
2. If a question is NOT related to sports or courts, you MUST politely refuse.
   Examples you MUST refuse:
   - math questions (2+2)
   - colors of objects (banana color)
   - meanings of non-sports objects (chair, table)
3. You ARE allowed to answer:
   - "What is sport?"
   - "Meaning of badminton"
   - "Football rules"

LANGUAGE:
- Understand English, Roman Urdu, and mixed language
- Handle spelling mistakes intelligently

DATA RULES:
- NEVER invent courts, prices, locations, or bookings
- If app data is required, respond with:
  "__FETCH_COURTS__"
  followed by optional filters:
  sport=<sport or empty>
  city=<city or empty>

VERY IMPORTANT RULE:
If the user asks ANYTHING that implies listing, showing, finding, or filtering courts
(e.g.:
- "courts in karachi"
- "courts in courtwala"
- "show courts"
- "badminton courts"
- "available courts")
you MUST treat it as APP DATA REQUEST.

FOR APP DATA REQUESTS:
Respond ONLY in this exact format:

__FETCH_COURTS__
sport=<sport or empty>
city=<city or empty>

If a filter is not mentioned, leave it empty.
DO NOT explain.
DO NOT refuse.
DO NOT answer in text.

STYLE:
- Short, clear, friendly
- If refusing, explain briefly why
`.trim();

/**
 * ================= PUBLIC CHAT =================
 */
router.post("/", async (req, res) => {
  const { message } = req.body;

  if (!message || typeof message !== "string") {
    return res.status(400).json({
      type: "AI",
      reply: "Message is required.",
    });
  }

  try {
    const completion = await client.chat.completions.create({
      model: "gpt-4o-mini",
      max_completion_tokens: 220,
      messages: [
        { role: "system", content: AI_PROMPT },
        { role: "user", content: message },
      ],
    });

    const aiReply = completion.choices[0].message.content.trim();

    /**
     * ===== AI REQUESTING COURTS =====
     */
    if (aiReply.startsWith("__FETCH_COURTS__")) {
      const sportMatch = aiReply.match(/sport=(.*)/i);
      const cityMatch = aiReply.match(/city=(.*)/i);

      const sport =
        sportMatch && sportMatch[1].trim()
          ? sportMatch[1].trim().toLowerCase()
          : null;

      const city =
        cityMatch && cityMatch[1].trim()
          ? cityMatch[1].trim().toLowerCase()
          : null;

      const courts = await prisma.court.findMany({
        where: {
          status: "ACTIVE",
          ...(sport
            ? { sportType: { contains: sport } } // ✅ FIXED
            : {}),
          ...(city
            ? { city: { contains: city } } // ✅ FIXED
            : {}),
        },
        take: 10,
      });

      return res.json({
        type: "DATA",
        reply:
          courts.length === 0
            ? "No courts found matching your criteria."
            : courts
                .map(
                  c => `🏟 ${c.name}
📍 ${c.location}, ${c.city}
🏸 Sport: ${c.sportType}
💰 PKR ${c.pricePerHour}
🗺 ${c.mapUrl || "Map not available"}`
                )
                .join("\n\n"),
      });
    }

    /**
     * ===== NORMAL AI RESPONSE =====
     */
    return res.json({
      type: "AI",
      reply: aiReply,
    });

  } catch (error) {
    console.error("Chatbot error:", error);
    return res.status(500).json({
      type: "AI",
      reply: "AI service unavailable.",
    });
  }
});

module.exports = router;
