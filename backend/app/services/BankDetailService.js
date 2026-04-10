const prisma = require('../../config/database');
const { AppError } = require('../utils/ErrorHandler');

class BankDetailService {
  /**
   * Add a new bank detail for an owner
   */
  static async create(ownerId, data) {
    const { provider, accountName, accountNumber, isActive = true } = data;

    if (!provider || !accountName || !accountNumber) {
      throw new AppError('Provider, Account Name, and Account Number are required', 400);
    }

    const newBankDetail = await prisma.bankDetail.create({
      data: {
        ownerId,
        provider,
        accountName,
        accountNumber,
        isActive,
      },
    });

    return newBankDetail;
  }

  /**
   * Get all bank details for an owner
   */
  static async getByOwner(ownerId) {
    return prisma.bankDetail.findMany({
      where: { ownerId },
      orderBy: { createdAt: 'desc' },
    });
  }

  /**
   * Get dynamic active bank details linked to a courtId
   */
  static async getActiveByCourt(courtId) {
    const court = await prisma.court.findUnique({
      where: { id: courtId },
      select: { ownerId: true },
    });

    if (!court) throw new AppError('Court not found', 404);

    return prisma.bankDetail.findMany({
      where: {
        ownerId: court.ownerId,
        isActive: true,
      },
    });
  }

  /**
   * Update bank detail
   */
  static async update(id, ownerId, data) {
    const bankDetail = await prisma.bankDetail.findUnique({ where: { id } });

    if (!bankDetail) throw new AppError('Bank detail not found', 404);
    if (bankDetail.ownerId !== ownerId) throw new AppError('Unauthorized', 403);

    return prisma.bankDetail.update({
      where: { id },
      data,
    });
  }

  /**
   * Delete a bank detail
   */
  static async delete(id, ownerId) {
    const bankDetail = await prisma.bankDetail.findUnique({ where: { id } });

    if (!bankDetail) throw new AppError('Bank detail not found', 404);
    if (bankDetail.ownerId !== ownerId) throw new AppError('Unauthorized', 403);

    await prisma.bankDetail.delete({ where: { id } });
    return true;
  }
}

module.exports = BankDetailService;
