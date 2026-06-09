import { Controller } from '@nestjs/common';
import { MessagePattern, Payload, RpcException } from '@nestjs/microservices';
import { PurchaseService } from './purchase.service';

@Controller()
export class PurchaseController {
  constructor(private readonly purchaseService: PurchaseService) {}

  @MessagePattern('inventory.po.create')
  async createPurchaseOrder(@Payload() data: any) {
    try {
      return await this.purchaseService.createPurchaseOrder(data);
    } catch (error) {
      if (error instanceof RpcException) throw error;
      throw new RpcException(error.message || 'Lỗi hệ thống khi tạo đơn nhập');
    }
  }

  @MessagePattern('inventory.grn.create')
  async createGoodsReceiptNote(@Payload() data: any) {
    try {
      return await this.purchaseService.createGoodsReceiptNote(data);
    } catch (error) {
      if (error instanceof RpcException) throw error;
      throw new RpcException(error.message || 'Lỗi hệ thống khi tạo phiếu nhập kho');
    }
  }

  @MessagePattern('inventory.po.list')
  async listPurchaseOrders(@Payload() query: any) {
    try {
      return await this.purchaseService.listPurchaseOrders(query);
    } catch (error) {
      throw new RpcException(error.message || 'Lỗi hệ thống khi lấy danh sách đơn nhập');
    }
  }

  @MessagePattern('inventory.po.get_by_id')
  async getPurchaseOrderById(@Payload() data: { id: string }) {
    try {
      return await this.purchaseService.getPurchaseOrderById(data.id);
    } catch (error) {
      throw new RpcException(error.message || 'Lỗi hệ thống khi lấy chi tiết đơn nhập');
    }
  }

  @MessagePattern('inventory.grn.list')
  async listGoodsReceiptNotes() {
    try {
      return await this.purchaseService.listGoodsReceiptNotes();
    } catch (error) {
      throw new RpcException(error.message || 'Lỗi hệ thống khi lấy danh sách phiếu nhập kho');
    }
  }
}
