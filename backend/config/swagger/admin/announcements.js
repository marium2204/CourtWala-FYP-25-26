/**
 * @swagger
 * /admin/announcements:
 *   get:
 *     summary: Get all announcements
 *     tags: [Admin]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: page
 *         schema:
 *           type: integer
 *           default: 1
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *           default: 20
 *     responses:
 *       200:
 *         description: Announcements retrieved successfully
 *         content:
 *           application/json:
 *             schema:
 *               allOf:
 *                 - $ref: '#/components/schemas/SuccessResponse'
 *                 - type: object
 *                   properties:
 *                     data:
 *                       type: object
 *                       properties:
 *                         announcements:
 *                           type: array
 *                           items:
 *                             type: object
 *                             properties:
 *                               id:
 *                                 type: string
 *                               title:
 *                                 type: string
 *                               message:
 *                                 type: string
 *                               targetAudience:
 *                                 type: array
 *                                 items:
 *                                   type: string
 *                               scheduledAt:
 *                                 type: string
 *                                 format: date-time
 *                               isActive:
 *                                 type: boolean
 *                               createdAt:
 *                                 type: string
 *                                 format: date-time
 *       401:
 *         description: Unauthorized
 *       403:
 *         description: Forbidden - Admin access required
 *   post:
 *     summary: Create a new announcement
 *     tags: [Admin]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - title
 *               - message
 *               - targetAudience
 *             properties:
 *               title:
 *                 type: string
 *                 minLength: 3
 *                 maxLength: 200
 *                 example: System Maintenance
 *               message:
 *                 type: string
 *                 minLength: 10
 *                 maxLength: 2000
 *                 example: The system will be under maintenance on Sunday
 *               targetAudience:
 *                 type: array
 *                 items:
 *                   type: string
 *                   enum: [PLAYER, COURT_OWNER]
 *                 minItems: 1
 *                 example: [PLAYER, COURT_OWNER]
 *               scheduledAt:
 *                 type: string
 *                 format: date-time
 *                 example: '2024-06-01T00:00:00.000Z'
 *     responses:
 *       201:
 *         description: Announcement created successfully
 *         content:
 *           application/json:
 *             schema:
 *               allOf:
 *                 - $ref: '#/components/schemas/SuccessResponse'
 *                 - type: object
 *                   properties:
 *                     data:
 *                       type: object
 *                       properties:
 *                         id:
 *                           type: string
 *                         title:
 *                           type: string
 *                         message:
 *                           type: string
 *                         targetAudience:
 *                           type: array
 *                           items:
 *                             type: string
 *                         scheduledAt:
 *                           type: string
 *                           format: date-time
 *                         isActive:
 *                           type: boolean
 *       401:
 *         description: Unauthorized
 *       403:
 *         description: Forbidden - Admin access required
 *       422:
 *         description: Validation error
 */

