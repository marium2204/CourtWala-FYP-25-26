const prisma = require('../../config/database');
const { AppError } = require('../utils/ErrorHandler');

class PostService {
  /**
   * Create a post with attachments
   */
  static async createPost(userId, data) {
    const { content, attachments } = data;

    // Validate attachments
    const imageCount = attachments.filter(a => a.type === 'IMAGE').length;
    const videoCount = attachments.filter(a => a.type === 'VIDEO').length;

    if (imageCount > 5) throw new AppError('Max 5 images allowed', 400);
    if (videoCount > 1) throw new AppError('Max 1 video allowed', 400);

    return await prisma.post.create({
      data: {
        userId,
        content,
        attachments: {
          create: attachments.map(a => ({
            url: a.url,
            type: a.type
          }))
        }
      },
      include: {
        user: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
            profilePicture: true
          }
        },
        attachments: true,
        _count: {
          select: {
            comments: true,
            reactions: true
          }
        }
      }
    });
  }

  /**
   * Get paginated feed
   */
  static async getFeed(userId, { page = 1, limit = 10 }) {
    const skip = (page - 1) * limit;

    const [posts, total] = await Promise.all([
      prisma.post.findMany({
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
        include: {
          user: {
            select: {
              id: true,
              firstName: true,
              lastName: true,
              profilePicture: true
            }
          },
          attachments: true,
          reactions: true,
          _count: {
            select: {
              comments: true,
              reactions: true
            }
          }
        }
      }),
      prisma.post.count()
    ]);

    // Process posts to include reaction counts and user reaction status
    const processedPosts = posts.map(post => {
      const reactionCounts = post.reactions.reduce((acc, r) => {
        acc[r.type] = (acc[r.type] || 0) + 1;
        return acc;
      }, {});

      const userReaction = post.reactions.find(r => r.userId === userId);

      // Remove reactions array from response to keep it clean
      const { reactions, ...rest } = post;

      return {
        ...rest,
        reactionCounts,
        userHasReacted: !!userReaction,
        userReactionType: userReaction ? userReaction.type : null
      };
    });

    return {
      posts: processedPosts,
      pagination: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit)
      }
    };
  }

  /**
   * Toggle reaction
   */
  static async toggleReaction(userId, postId, type) {
    const existing = await prisma.reaction.findUnique({
      where: {
        userId_postId: { userId, postId }
      }
    });

    if (existing) {
      if (existing.type === type) {
        // Undo reaction
        await prisma.reaction.delete({
          where: { id: existing.id }
        });
        return { action: 'REMOVED' };
      } else {
        // Update reaction type
        const updated = await prisma.reaction.update({
          where: { id: existing.id },
          data: { type }
        });
        return { action: 'UPDATED', reaction: updated };
      }
    } else {
      // Create reaction
      const created = await prisma.reaction.create({
        data: { userId, postId, type }
      });
      return { action: 'CREATED', reaction: created };
    }
  }

  /**
   * Add comment
   */
  static async addComment(userId, postId, content) {
    return await prisma.comment.create({
      data: { userId, postId, content },
      include: {
        user: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
            profilePicture: true
          }
        }
      }
    });
  }

  /**
   * Get post comments
   */
  static async getComments(postId, { page = 1, limit = 20 }) {
    const skip = (page - 1) * limit;

    const [comments, total] = await Promise.all([
      prisma.comment.findMany({
        where: { postId },
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
        include: {
          user: {
            select: {
              id: true,
              firstName: true,
              lastName: true,
              profilePicture: true
            }
          }
        }
      }),
      prisma.comment.count({ where: { postId } })
    ]);

    return {
      comments,
      pagination: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit)
      }
    };
  }
}

module.exports = PostService;
