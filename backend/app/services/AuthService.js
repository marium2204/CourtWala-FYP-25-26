const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const crypto = require('crypto');
const config = require('../../config/app');
const prisma = require('../../config/database');
const { AppError } = require('../utils/ErrorHandler');
const admin = require('../../config/firebase');

class AuthService {
  static generateToken(userId) {
    return jwt.sign({ userId }, config.jwt.secret, {
      expiresIn: config.jwt.expiresIn,
    });
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

    return { user, token: this.generateToken(user.id) };
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

    return { user, token: this.generateToken(user.id) };
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

    return { user, token: this.generateToken(user.id) };
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

    return { user, token: this.generateToken(user.id) };
  }
}

module.exports = AuthService;
