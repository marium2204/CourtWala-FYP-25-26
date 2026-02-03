const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const crypto = require('crypto');
const config = require('../../config/app');
const prisma = require('../../config/database');
const { AppError } = require('../utils/ErrorHandler');
const admin = require('../../config/firebase');
const sendEmail = require('../utils/sendemail');

class AuthService {
  static generateToken(user) {
  return jwt.sign(
    {
      id: user.id,        // ✅ Flutter expects this
      role: user.role,    // ✅ Flutter expects this
    },
    config.jwt.secret,
    { expiresIn: config.jwt.expiresIn }
  );
}

  /* =========================
     REGISTER (EMAIL)
  ========================= */
  static async register(data) {
    const {
      email,
      password,
      firstName,
      lastName,
      role = 'PLAYER',
      username,
      phone,
      profilePicture,
    } = data;

    const existingUser = await prisma.user.findFirst({
      where: {
        OR: [{ email }, ...(username ? [{ username }] : [])],
      },
    });

    if (existingUser) {
      throw new AppError('User already exists', 409);
    }

    const hashedPassword = await bcrypt.hash(
      password,
      config.bcrypt.saltRounds
    );

    const user = await prisma.user.create({
      data: {
        email,
        password: hashedPassword,
        firstName,
        lastName,
        username,
        phone,
        profilePicture,
        role,
        status: role === 'COURT_OWNER' ? 'PENDING_APPROVAL' : 'ACTIVE',
        provider: 'EMAIL',
      },
    });

    return { user, token: this.generateToken(user) };
  }

  /* =========================
     LOGIN (EMAIL)
  ========================= */
  static async login(emailOrUsername, password) {
    const user = await prisma.user.findFirst({
      where: {
        OR: [{ email: emailOrUsername }, { username: emailOrUsername }],
      },
    });

    if (!user) throw new AppError('Invalid credentials', 401);

    if (user.provider === 'GOOGLE') {
      throw new AppError(
        'This account uses Google Sign-In',
        400
      );
    }

    const valid = await bcrypt.compare(password, user.password);
    if (!valid) throw new AppError('Invalid credentials', 401);

    return { user, token: this.generateToken(user) };
  }

  /* =========================
     GOOGLE LOGIN (EXISTING ONLY)
  ========================= */
  static async googleLogin(firebaseIdToken) {
    const decoded = await admin.auth().verifyIdToken(firebaseIdToken);
    const user = await prisma.user.findUnique({
      where: { email: decoded.email },
    });

    if (!user)
      throw new AppError(
        'No account found. Please sign up first.',
        404
      );

    if (!user.role)
      throw new AppError(
        'Account setup incomplete',
        400
      );

    return { user, token: this.generateToken(user) };
  }

  /* =========================
     GOOGLE SIGNUP (ROLE ONCE)
  ========================= */
  static async googleComplete(firebaseIdToken, role) {
    const decoded = await admin.auth().verifyIdToken(firebaseIdToken);
    const { email, name, uid, picture } = decoded;

    let user = await prisma.user.findUnique({ where: { email } });

    // ❌ EXISTING USER CANNOT CHANGE ROLE
    if (user && user.role) {
      throw new AppError(
        'Role already set for this account',
        409
      );
    }

    if (!user) {
      user = await prisma.user.create({
        data: {
          email,
          firstName: name?.split(' ')[0] || 'Google',
          lastName: name?.split(' ').slice(1).join(' ') || 'User',
          googleId: uid,
          profilePicture: picture,
          role,
          provider: 'GOOGLE',
          status: role === 'COURT_OWNER'
            ? 'PENDING_APPROVAL'
            : 'ACTIVE',
        },
      });
    } else {
      user = await prisma.user.update({
        where: { id: user.id },
        data: { role },
      });
    }

    return { user, token: this.generateToken(user) };
  }

/* =========================
   PASSWORD RESET (OTP)
========================= */
static async sendResetOtp(email) {
  const user = await prisma.user.findUnique({
    where: { email },
  });

  if (!user) {
    throw new AppError('User not found', 404);
  }

  if (user.provider === 'GOOGLE') {
    throw new AppError(
      'Password reset not available for Google accounts',
      400
    );
  }

  // Generate 6-digit OTP
  const otp = Math.floor(100000 + Math.random() * 900000).toString();

  await prisma.user.update({
    where: { id: user.id },
    data: {
      resetOtp: otp,
      resetOtpExpires: new Date(Date.now() + 15 * 60 * 1000),
    },
  });

  await sendEmail({
    to: email,
    subject: 'CourtWala Password Reset OTP',
    html: `
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8" />
    <title>CourtWala Password Reset</title>
  </head>
  <body style="
    margin: 0;
    padding: 0;
    background-color: #f4f6f8;
    font-family: Arial, Helvetica, sans-serif;
  ">
    <table width="100%" cellpadding="0" cellspacing="0">
      <tr>
        <td align="center" style="padding: 30px 15px;">
          <table width="100%" max-width="480" style="
            background-color: #ffffff;
            border-radius: 12px;
            box-shadow: 0 8px 24px rgba(0,0,0,0.08);
            overflow: hidden;
          ">
            <!-- Header -->
            <tr>
              <td style="
                background-color: #65AAC2;
                padding: 24px;
                text-align: center;
                color: #ffffff;
              ">
                <h1 style="
                  margin: 0;
                  font-size: 24px;
                  font-weight: bold;
                ">
                  CourtWala
                </h1>
                <p style="
                  margin: 6px 0 0;
                  font-size: 14px;
                  opacity: 0.9;
                ">
                  Password Reset Request
                </p>
              </td>
            </tr>

            <!-- Body -->
            <tr>
              <td style="padding: 28px;">
                <p style="
                  font-size: 16px;
                  color: #333333;
                  margin: 0 0 12px;
                ">
                  Hi,
                </p>

                <p style="
                  font-size: 15px;
                  color: #555555;
                  margin: 0 0 20px;
                  line-height: 1.5;
                ">
                  We received a request to reset your CourtWala account password.
                  Use the OTP below to continue.
                </p>

                <!-- OTP Box -->
                <div style="
                  text-align: center;
                  margin: 24px 0;
                ">
                  <div style="
                    display: inline-block;
                    padding: 16px 28px;
                    font-size: 28px;
                    letter-spacing: 6px;
                    font-weight: bold;
                    color: #65AAC2;
                    background-color: #f0f8fb;
                    border-radius: 10px;
                  ">
                    ${otp}
                  </div>
                </div>

                <p style="
                  font-size: 14px;
                  color: #666666;
                  margin: 0 0 16px;
                ">
                  ⏱ This OTP will expire in <strong>15 minutes</strong>.
                </p>

                <p style="
                  font-size: 14px;
                  color: #888888;
                  margin: 0;
                ">
                  If you didn’t request a password reset, you can safely ignore
                  this email.
                </p>
              </td>
            </tr>

            <!-- Footer -->
            <tr>
              <td style="
                background-color: #fafafa;
                padding: 16px;
                text-align: center;
                font-size: 12px;
                color: #999999;
              ">
                © ${new Date().getFullYear()} CourtWala  
                <br />
                All rights reserved.
              </td>
            </tr>
          </table>
        </td>
      </tr>
    </table>
  </body>
</html>
`,

  });

  return true;
}

static async resetPasswordWithOtp(email, otp, newPassword) {
  const user = await prisma.user.findUnique({
    where: { email },
  });

  if (
    !user ||
    user.resetOtp !== otp ||
    !user.resetOtpExpires ||
    user.resetOtpExpires < new Date()
  ) {
    throw new AppError('Invalid or expired OTP', 400);
  }

  const hashedPassword = await bcrypt.hash(
    newPassword,
    config.bcrypt.saltRounds
  );

  await prisma.user.update({
    where: { id: user.id },
    data: {
      password: hashedPassword,
      resetOtp: null,
      resetOtpExpires: null,
    },
  });

  return true;
}
}

  
module.exports = AuthService;
