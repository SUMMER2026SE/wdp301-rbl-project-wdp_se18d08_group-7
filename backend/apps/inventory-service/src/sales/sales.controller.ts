import { Controller } from '@nestjs/common';
import { MessagePattern, Payload, RpcException } from '@nestjs/microservices';
import { SalesService } from './sales.service';

@Controller()
export class SalesController {
  constructor(private readonly salesService: SalesService) {}

  @MessagePattern('inventory.prescription.get')
  async getPrescriptionByCode(@Payload() data: { code: string }) {
    try {
      return await this.salesService.getPrescriptionByCode(data.code);
    } catch (error) {
      if (error instanceof RpcException) throw error;
      throw new RpcException(error.message || 'Lỗi hệ thống khi lấy thông tin đơn thuốc');
    }
  }

  @MessagePattern('inventory.prescription.list')
  async listPrescriptions() {
    try {
      return await this.salesService.listPrescriptions();
    } catch (error) {
      if (error instanceof RpcException) throw error;
      throw new RpcException(error.message || 'Lỗi hệ thống khi lấy danh sách đơn thuốc');
    }
  }

  @MessagePattern('inventory.sale.create')
  async createSalesOrder(@Payload() data: any) {
    try {
      return await this.salesService.createSalesOrder(data);
    } catch (error) {
      if (error instanceof RpcException) throw error;
      throw new RpcException(error.message || 'Lỗi hệ thống khi tạo đơn bán hàng');
    }
  }

  @MessagePattern('inventory.sale.list')
  async listSalesOrders() {
    try {
      return await this.salesService.listSalesOrders();
    } catch (error) {
      throw new RpcException(error.message || 'Lỗi hệ thống khi lấy danh sách đơn bán hàng');
    }
  }
}
