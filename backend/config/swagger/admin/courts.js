/**
 * @swagger
 * /admin/courts:
 *   get:
 *     summary: Get all courts for admin management
 *     tags: [Admin]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: status
 *         schema:
 *           type: string
 *           enum: [PENDING, PENDING_APPROVAL, ACTIVE, INACTIVE, REJECTED, APPROVED]
 *         description: Filter by status (PENDING/PENDING_APPROVAL are equivalent, APPROVED maps to ACTIVE)
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
 *         description: Courts retrieved successfully
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
 *                         courts:
 *                           type: array
 *                           items:
 *                             $ref: '#/components/schemas/Court'
 *                         pagination:
 *                           type: object
 *       401:
 *         description: Unauthorized
 *       403:
 *         description: Forbidden - Admin access required
 */

/**
 * @swagger
 * /admin/courts/{id}/status:
 *   put:
 *     summary: Update court approval status
 *     tags: [Admin]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: Court ID
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - status
 *             properties:
 *               status:
 *                 type: string
 *                 enum: [ACTIVE, INACTIVE, REJECTED, APPROVED]
 *                 description: Status value (APPROVED maps to ACTIVE)
 *                 example: ACTIVE
 *               reason:
 *                 type: string
 *                 example: Court meets all requirements
 *     responses:
 *       200:
 *         description: Court status updated successfully
 *         content:
 *           application/json:
 *             schema:
 *               allOf:
 *                 - $ref: '#/components/schemas/SuccessResponse'
 *                 - type: object
 *                   properties:
 *                     data:
 *                       $ref: '#/components/schemas/Court'
 *       401:
 *         description: Unauthorized
 *       403:
 *         description: Forbidden - Admin access required
 *       404:
 *         description: Court not found
 */

