const prisma = require('../../config/database');

class NotificationService {
  /**
   * Create notification
   */
  static async create(data) {
    const { receiverId, senderId, type, title, message, data: additionalData } = data;

    return prisma.notification.create({
      data: {
        receiverId,
        senderId,
        type,
        title,
        message,
        data: additionalData ? JSON.parse(JSON.stringify(additionalData)) : null,
      },
    });
  }

  /**
   * Get user notifications
   */
  static async getUserNotifications(userId, filters = {}) {
    const { isRead, type, limit = 50, page = 1 } = filters;
    const skip = (page - 1) * limit;

    const where = {
      receiverId: userId,
      ...(isRead !== undefined && { isRead }),
      ...(type && { type }),
    };

    const [notifications, total] = await Promise.all([
      prisma.notification.findMany({
        where,
        orderBy: { createdAt: 'desc' },
        skip,
        take: limit,
        include: {
          sender: {
            select: {
              id: true,
              firstName: true,
              lastName: true,
              profilePicture: true,
            },
          },
        },
      }),
      prisma.notification.count({ where }),
    ]);

    return {
      notifications,
      pagination: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  /**
   * Mark notification as read
   */
  static async markAsRead(notificationId, userId) {
    return prisma.notification.updateMany({
      where: {
        id: notificationId,
        receiverId: userId,
      },
      data: {
        isRead: true,
      },
    });
  }

  /**
   * Mark all notifications as read
   */
  static async markAllAsRead(userId) {
    return prisma.notification.updateMany({
      where: {
        receiverId: userId,
        isRead: false,
      },
      data: {
        isRead: true,
      },
    });
  }

  /**
   * Get unread count
   */
  static async getUnreadCount(userId) {
    return prisma.notification.count({
      where: {
        receiverId: userId,
        isRead: false,
      },
    });
  }
}

module.exports = NotificationService;

