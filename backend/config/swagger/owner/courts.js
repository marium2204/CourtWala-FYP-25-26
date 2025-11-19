/**
 * @swagger
 * /owner/courts:
 *   get:
 *     summary: Get owner's courts
 *     tags: [Owner]
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
 *         description: Forbidden - Court owner access required
 *   post:
 *     summary: Create a new court
 *     tags: [Owner]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             required:
 *               - name
 *               - address
 *               - city
 *               - state
 *               - zipCode
 *               - sport
 *               - pricePerHour
 *             properties:
 *               name:
 *                 type: string
 *                 example: Central Court
 *               description:
 *                 type: string
 *                 example: A premium court facility
 *               address:
 *                 type: string
 *                 example: 123 Main St
 *               city:
 *                 type: string
 *                 example: New York
 *               state:
 *                 type: string
 *                 example: NY
 *               zipCode:
 *                 type: string
 *                 example: '10001'
 *               sport:
 *                 type: string
 *                 example: Tennis
 *               pricePerHour:
 *                 type: number
 *                 example: 50.00
 *               amenities:
 *                 type: array
 *                 items:
 *                   type: string
 *                 description: Comma-separated list or JSON array string
 *                 example: ["Parking", "Locker Room", "Showers"]
 *               images:
 *                 type: array
 *                 items:
 *                   type: string
 *                   format: binary
 *                 description: Court image files (JPEG, PNG, JPG, WEBP, max 5MB each, max 10 files)
 *     responses:
 *       201:
 *         description: Court created successfully
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
 *         description: Forbidden - Court owner access required
 *       422:
 *         description: Validation error
 */

/**
 * @swagger
 * /owner/courts/{id}:
 *   get:
 *     summary: Get court by ID
 *     tags: [Owner]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: Court ID
 *     responses:
 *       200:
 *         description: Court retrieved successfully
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
 *         description: Forbidden - Court owner access required
 *       404:
 *         description: Court not found
 *   put:
 *     summary: Update court
 *     tags: [Owner]
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
 *         multipart/form-data:
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
 *               address:
 *                 type: string
 *                 minLength: 3
 *                 maxLength: 200
 *               city:
 *                 type: string
 *                 minLength: 2
 *                 maxLength: 100
 *               state:
 *                 type: string
 *                 minLength: 2
 *                 maxLength: 50
 *               zipCode:
 *                 type: string
 *                 pattern: '^\d{5}(-\d{4})?$'
 *                 example: '10001'
 *               sport:
 *                 type: string
 *                 minLength: 2
 *                 maxLength: 50
 *               pricePerHour:
 *                 type: number
 *                 minimum: 0
 *               amenities:
 *                 type: array
 *                 items:
 *                   type: string
 *                 description: Comma-separated list or JSON array string
 *               images:
 *                 type: array
 *                 items:
 *                   type: string
 *                   format: binary
 *                 description: Court image files (JPEG, PNG, JPG, WEBP, max 5MB each, max 10 files)
 *     responses:
 *       200:
 *         description: Court updated successfully
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
 *         description: Forbidden - Court owner access required
 *       404:
 *         description: Court not found
 *   delete:
 *     summary: Delete court
 *     tags: [Owner]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: Court ID
 *     responses:
 *       200:
 *         description: Court deleted successfully
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/SuccessResponse'
 *       401:
 *         description: Unauthorized
 *       403:
 *         description: Forbidden - Court owner access required
 *       404:
 *         description: Court not found
 */

