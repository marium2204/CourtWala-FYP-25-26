/**
 * @swagger
 * /owner/dashboard:
 *   get:
 *     summary: Get owner dashboard statistics
 *     tags: [Owner]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Dashboard statistics retrieved successfully
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
 *                         totalCourts:
 *                           type: integer
 *                           example: 5
 *                         totalBookings:
 *                           type: integer
 *                           example: 120
 *                         pendingBookings:
 *                           type: integer
 *                           example: 8
 *                         approvedBookings:
 *                           type: integer
 *                           example: 95
 *                         totalRevenue:
 *                           type: number
 *                           example: 12500.00
 *                         monthlyRevenue:
 *                           type: number
 *                           example: 2500.00
 *       401:
 *         description: Unauthorized
 *       403:
 *         description: Forbidden - Court owner access required
 */

