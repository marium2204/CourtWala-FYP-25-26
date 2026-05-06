const BaseController = require('../BaseController');
const PostService = require('../../services/PostService');
const { asyncHandler } = require('../../utils/ErrorHandler');

class PostController extends BaseController {
  /**
   * Create post
   */
  static create = asyncHandler(async (req, res) => {
    const post = await PostService.createPost(req.user.id, req.body);
    return BaseController.success(res, post, 'Post created successfully', 201);
  });

  /**
   * Get feed
   */
  static getFeed = asyncHandler(async (req, res) => {
    const { page, limit } = req.query;
    const result = await PostService.getFeed(req.user.id, {
      page: parseInt(page) || 1,
      limit: parseInt(limit) || 10
    });
    return BaseController.success(res, result, 'Feed retrieved successfully');
  });

  /**
   * Toggle reaction
   */
  static toggleReaction = asyncHandler(async (req, res) => {
    const { type } = req.body;
    const { id: postId } = req.params;
    const result = await PostService.toggleReaction(req.user.id, postId, type);
    return BaseController.success(res, result, 'Reaction toggled successfully');
  });

  /**
   * Add comment
   */
  static addComment = asyncHandler(async (req, res) => {
    const { content } = req.body;
    const { id: postId } = req.params;
    const comment = await PostService.addComment(req.user.id, postId, content);
    return BaseController.success(res, comment, 'Comment added successfully', 201);
  });

  /**
   * Get comments
   */
  static getComments = asyncHandler(async (req, res) => {
    const { page, limit } = req.query;
    const { id: postId } = req.params;
    const result = await PostService.getComments(postId, {
      page: parseInt(page) || 1,
      limit: parseInt(limit) || 20
    });
    return BaseController.success(res, result, 'Comments retrieved successfully');
  });
}

module.exports = PostController;
