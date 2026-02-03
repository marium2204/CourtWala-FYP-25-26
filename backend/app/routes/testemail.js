const express = require("express");
const router = express.Router();
const sendEmail = require("../utils/sendemail");

router.get("/test-email", async (req, res) => {
  try {
    await sendEmail({
      to: "YOUR_PERSONAL_EMAIL@gmail.com", // 👈 change this
      subject: "CourtWala Test Email",
      html: "<h2>Email system working successfully ✅</h2>",
    });

    res.json({ message: "Test email sent successfully" });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Email failed", error });
  }
});

module.exports = router;
