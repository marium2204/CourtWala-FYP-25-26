/**
 * @swagger
 * /player/tournaments:
 *   get:
 *     summary: Get all tournaments
 *     tags: [Player]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: status
 *         schema:
 *           type: string
 *           enum: [UPCOMING, ONGOING, COMPLETED, CANCELLED]
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
 *         description: Tournaments retrieved successfully
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
 *                         tournaments:
 *                           type: array
 *                           items:
 *                             type: object
 *                             properties:
 *                               id:
 *                                 type: string
 *                               name:
 *                                 type: string
 *                               description:
 *                                 type: string
 *                               startDate:
 *                                 type: string
 *                                 format: date
 *                               endDate:
 *                                 type: string
 *                                 format: date
 *                               maxParticipants:
 *                                 type: integer
 *                               currentParticipants:
 *                                 type: integer
 *                               sport:
 *                                 type: string
 *                               skillLevel:
 *                                 type: string
 *                               status:
 *                                 type: string
 *                         pagination:
 *                           type: object
 *       401:
 *         description: Unauthorized
 *       403:
 *         description: Forbidden - Player access required
 */

/**
 * @swagger
 * /player/tournaments/{id}:
 *   get:
 *     summary: Get tournament details by ID
 *     tags: [Player]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: Tournament ID
 *     responses:
 *       200:
 *         description: Tournament details retrieved successfully
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
 *                         name:
 *                           type: string
 *                         description:
 *                           type: string
 *                         startDate:
 *                           type: string
 *                         endDate:
 *                           type: string
 *                         maxParticipants:
 *                           type: integer
 *                         currentParticipants:
 *                           type: integer
 *                         sport:
 *                           type: string
 *                         skillLevel:
 *                           type: string
 *                         status:
 *                           type: string
 *                         isJoined:
 *                           type: boolean
 *       401:
 *         description: Unauthorized
 *       403:
 *         description: Forbidden - Player access required
 *       404:
 *         description: Tournament not found
 */

/**
 * @swagger
 * /player/tournaments/{id}/join:
 *   post:
 *     summary: Join a tournament
 *     tags: [Player]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: Tournament ID
 *     responses:
 *       200:
 *         description: Successfully joined tournament
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/SuccessResponse'
 *       401:
 *         description: Unauthorized
 *       403:
 *         description: Forbidden - Player access required
 *       404:
 *         description: Tournament not found
 *       400:
 *         description: Cannot join tournament (full, already joined, etc.)
 */

/**
 * @swagger
 * /player/tournaments/{id}/leave:
 *   post:
 *     summary: Leave a tournament
 *     tags: [Player]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: Tournament ID
 *     responses:
 *       200:
 *         description: Successfully left tournament
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/SuccessResponse'
 *       401:
 *         description: Unauthorized
 *       403:
 *         description: Forbidden - Player access required
 *       404:
 *         description: Tournament not found
 *       400:
 *         description: Cannot leave tournament
 */

