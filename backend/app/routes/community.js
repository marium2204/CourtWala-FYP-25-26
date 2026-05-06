const express = require('express');
const router = express.Router();
const PostController = require('../controllers/Community/PostController');
const { authenticate } = require('../middleware/AuthMiddleware');

// All community routes require authentication
router.use(authenticate);

// Post routes
router.get('/posts', PostController.getFeed);
router.post('/posts', PostController.create);

// Reaction routes
router.post('/posts/:id/react', PostController.toggleReaction);

// Comment routes
router.get('/posts/:id/comments', PostController.getComments);
router.post('/posts/:id/comments', PostController.addComment);

module.exports = router;
