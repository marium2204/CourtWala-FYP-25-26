/**
 * @swagger
 * /player/reports:
 *   get:
 *     summary: Get player's reports
 *     tags: [Player]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: status
 *         schema:
 *           type: string
 *           enum: [PENDING, RESOLVED, DISMISSED]
 *         description: Filter by status
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
 *         description: Reports retrieved successfully
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
 *                         reports:
 *                           type: array
 *                           items:
 *                             type: object
 *                             properties:
 *                               id:
 *                                 type: string
 *                               type:
 *                                 type: string
 *                               reason:
 *                                 type: string
 *                               description:
 *                                 type: string
 *                               status:
 *                                 type: string
 *                               createdAt:
 *                                 type: string
 *                                 format: date-time
 *                         pagination:
 *                           type: object
 *       401:
 *         description: Unauthorized
 *       403:
 *         description: Forbidden - Player access required
 *   post:
 *     summary: Create a new report
 *     tags: [Player]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - type
 *               - reason
 *               - description
 *               - reportedId
 *             properties:
 *               type:
 *                 type: string
 *                 enum: [COURT, USER, BOOKING]
 *                 example: COURT
 *               reason:
 *                 type: string
 *                 example: Inappropriate behavior
 *               description:
 *                 type: string
 *                 example: Detailed description of the issue
 *               reportedId:
 *                 type: string
 *                 example: court123
 *     responses:
 *       201:
 *         description: Report created successfully
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
 *                         type:
 *                           type: string
 *                         reason:
 *                           type: string
 *                         description:
 *                           type: string
 *                         status:
 *                           type: string
 *       401:
 *         description: Unauthorized
 *       403:
 *         description: Forbidden - Player access required
 *       422:
 *         description: Validation error
 */

