const express = require("express");
const OpenAI = require("openai");
require("dotenv").config();

const router = express.Router();

// OpenAI client
const client = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

// Prompt to decide if the message is sports/court related
const TOPIC_CHECK_PROMPT = `
Reply only YES or NO.

Is this message about any of the following:
- sports
- courts
- games
- bookings
- sport facilities
- sport locations

Be generous. If unsure, reply YES.
`.trim();

// Main system prompt
const SYSTEM_PROMPT = `
You are CourtWala AI, an assistant for sports and court booking platform users.

Rules:
1. You answer sports and court related questions.
2. If the user asks about real-time data you don't have (like exact number of courts in a city),
   respond with:
   "I don’t have real-time data, but I can help you find courts or explain how to search."
3. Keep answers short, clear, and helpful.
`.trim();

/**
 * @swagger
 * /chat:
 *   post:
 *     summary: AI chatbot for sports & court related questions
 *     description: Smart AI assistant for sports and court domain queries.
 *     tags:
 *       - AI Chatbot
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               message:
 *                 type: string
 *                 example: "How do I book a tennis court?"
 *     responses:
 *       200:
 *         description: Chatbot reply
 *       400:
 *         description: Message is required
 *       500:
 *         description: Server error
 */
router.post("/", async (req, res) => {
  const { message } = req.body;

  // Input validation
  if (!message || typeof message !== "string") {
    return res.status(400).json({ reply: "Message is required." });
  }

  try {
    // Step 1: Topic detection
    const topicCheck = await client.chat.completions.create({
      model: "gpt-4o-mini",
      messages: [
        { role: "system", content: TOPIC_CHECK_PROMPT },
        { role: "user", content: message },
      ],
    });

    const isRelated =
      topicCheck.choices[0].message.content.trim().toUpperCase() === "YES";

    // Step 2: Reject unrelated queries
    if (!isRelated) {
      return res.json({
        reply: "Sorry — I can only answer sports- or court-related questions.",
      });
    }

    // Step 3: Generate final answer
    const completion = await client.chat.completions.create({
      model: "gpt-4o-mini",
      messages: [
        { role: "system", content: SYSTEM_PROMPT },
        { role: "user", content: message },
      ],
    });

    return res.json({
      reply: completion.choices[0].message.content,
    });

  } catch (error) {
    console.error("Chatbot error:", error);
    return res.status(500).json({
      reply: "AI service unavailable. Please try again later.",
    });
  }
});

module.exports = router;
