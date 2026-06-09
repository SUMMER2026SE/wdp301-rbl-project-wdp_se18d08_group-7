import { Controller } from '@nestjs/common';
import { MessagePattern, Payload, RpcException } from '@nestjs/microservices';
import { MedicineService } from './medicine.service';

@Controller()
export class MedicineController {
  constructor(private readonly medicineService: MedicineService) {}

  @MessagePattern('inventory.medicine.list')
  async listMedicines(@Payload() query: any) {
    try {
      return await this.medicineService.listMedicines(query);
    } catch (error) {
      if (error instanceof RpcException) throw error;
      throw new RpcException(error.message || 'Lỗi hệ thống khi lấy danh sách thuốc');
    }
  }

  @MessagePattern('inventory.medicine.get_by_id')
  async getMedicineById(@Payload() data: { id: string }) {
    try {
      return await this.medicineService.getMedicineById(data.id);
    } catch (error) {
      if (error instanceof RpcException) throw error;
      throw new RpcException(error.message || 'Lỗi hệ thống khi lấy chi tiết thuốc');
    }
  }

  @MessagePattern('inventory.medicine.update_status')
  async updateMedicineStatus(@Payload() data: { id: string; status: string; stock?: number }) {
    try {
      return await this.medicineService.updateMedicineStatus(data.id, data.status, data.stock);
    } catch (error) {
      if (error instanceof RpcException) throw error;
      throw new RpcException(error.message || 'Lỗi hệ thống khi cập nhật trạng thái thuốc');
    }
  }

  @MessagePattern('inventory.medicine.get_filters')
  async getMedicineFilters() {
    try {
      return await this.medicineService.getMedicineFilters();
    } catch (error) {
      if (error instanceof RpcException) throw error;
      throw new RpcException(error.message || 'Lỗi hệ thống khi lấy bộ lọc thuốc');
    }
  }
}
