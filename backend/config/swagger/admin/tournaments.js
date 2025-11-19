/**
 * @swagger
 * /admin/tournaments:
 *   post:
 *     summary: Create a new tournament
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
 *               - name
 *               - sport
 *               - startDate
 *               - endDate
 *               - maxParticipants
 *             properties:
 *               name:
 *                 type: string
 *                 example: Summer Championship 2024
 *               description:
 *                 type: string
 *                 example: Annual summer tournament
 *               sport:
 *                 type: string
 *                 example: Tennis
 *               skillLevel:
 *                 type: string
 *                 enum: [BEGINNER, INTERMEDIATE, ADVANCED, PROFESSIONAL]
 *                 example: INTERMEDIATE
 *               startDate:
 *                 type: string
 *                 format: date-time
 *                 example: '2024-06-01T00:00:00.000Z'
 *               endDate:
 *                 type: string
 *                 format: date-time
 *                 example: '2024-06-30T23:59:59.000Z'
 *               maxParticipants:
 *                 type: integer
 *                 minimum: 2
 *                 example: 32
 *     responses:
 *       201:
 *         description: Tournament created successfully
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
 *       401:
 *         description: Unauthorized
 *       403:
 *         description: Forbidden - Admin access required
 *       422:
 *         description: Validation error
 */

/**
 * @swagger
 * /admin/tournaments/{id}:
 *   put:
 *     summary: Update a tournament
 *     tags: [Admin]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: Tournament ID
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               name:
 *                 type: string
 *                 minLength: 3
 *                 maxLength: 100
 *               description:
 *                 type: string
 *                 maxLength: 1000
 *               sport:
 *                 type: string
 *                 minLength: 2
 *                 maxLength: 50
 *               skillLevel:
 *                 type: string
 *                 enum: [BEGINNER, INTERMEDIATE, ADVANCED, PROFESSIONAL]
 *               startDate:
 *                 type: string
 *                 format: date-time
 *               endDate:
 *                 type: string
 *                 format: date-time
 *               maxParticipants:
 *                 type: integer
 *                 minimum: 2
 *               status:
 *                 type: string
 *                 enum: [UPCOMING, ONGOING, COMPLETED, CANCELLED]
 *     responses:
 *       200:
 *         description: Tournament updated successfully
 *         content:
 *           application/json:
 *             schema:
 *               allOf:
 *                 - $ref: '#/components/schemas/SuccessResponse'
 *                 - type: object
 *                   properties:
 *                     data:
 *                       type: object
 *       401:
 *         description: Unauthorized
 *       403:
 *         description: Forbidden - Admin access required
 *       404:
 *         description: Tournament not found
 *   delete:
 *     summary: Delete a tournament
 *     tags: [Admin]
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
 *         description: Tournament deleted successfully
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/SuccessResponse'
 *       401:
 *         description: Unauthorized
 *       403:
 *         description: Forbidden - Admin access required
 *       404:
 *         description: Tournament not found
 */

