const jwt = require('jsonwebtoken');
const config = require('../../config/app');
const prisma = require('../../config/database');
const ResponseHandler = require('../utils/ResponseHandler');
const { AppError } = require('../utils/ErrorHandler');

/**
 * Verify JWT token and attach user to request
 */
const authenticate = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      throw new AppError('Authentication token required', 401);
    }

    const token = authHeader.split(' ')[1];

    // 🚫 Catch "null" or empty tokens
    if (!token || token === 'null') {
      throw new AppError('Invalid authentication token', 401);
    }

    const decoded = jwt.verify(token, config.jwt.secret);

    // 🚫 Token payload corrupted
    if (!decoded?.id) {
      throw new AppError('Invalid token payload', 401);
    }

    const user = await prisma.user.findUnique({
      where: { id: decoded.id }, // ✅ FIXED
      select: {
        id: true,
        email: true,
        username: true,
        firstName: true,
        lastName: true,
        role: true,
        status: true,
        profilePicture: true,
      },
    });

    if (!user) {
      throw new AppError('User not found', 401);
    }

    if (user.status !== 'ACTIVE' && user.role !== 'ADMIN') {
      throw new AppError('Account is not active', 403);
    }

    req.user = user;
    next();
  } catch (error) {
    if (
      error.name === 'JsonWebTokenError' ||
      error.name === 'TokenExpiredError'
    ) {
      return ResponseHandler.unauthorized(res, 'Invalid or expired token');
    }
    next(error);
  }
};

/**
 * Role-based access control middleware
 */
const authorize = (...roles) => {
  return (req, res, next) => {
    if (!req.user) {
      return ResponseHandler.unauthorized(res, 'Authentication required');
    }

    if (!roles.includes(req.user.role)) {
      return ResponseHandler.forbidden(res, 'Insufficient permissions');
    }

    next();
  };
};

/**
 * Check if user owns resource
 */
const isOwner = (resourceOwnerId) => {
  return (req, res, next) => {
    if (req.user.role === 'ADMIN') {
      return next();
    }

    if (req.user.id !== resourceOwnerId) {
      return ResponseHandler.forbidden(
        res,
        'You do not have permission to access this resource'
      );
    }

    next();
  };
};

module.exports = {
  authenticate,
  authorize,
  isOwner,
};
