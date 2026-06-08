import { Controller, Post, Get, Body, Inject, OnModuleInit } from '@nestjs/common';
import { ClientKafka } from '@nestjs/microservices';
import { sendKafkaMessage, subscribeToKafkaTopics } from './common/kafka.helper';

@Controller('api/sales')
export class SalesController implements OnModuleInit {
  constructor(
    @Inject('INVENTORY_SERVICE') private readonly inventoryClient: ClientKafka,
  ) {}

  async onModuleInit() {
    await subscribeToKafkaTopics(this.inventoryClient, [
      'inventory.sale.create',
      'inventory.sale.list',
    ]);
  }

  @Post()
  async createSalesOrder(@Body() data: any) {
    return await sendKafkaMessage(this.inventoryClient, 'inventory.sale.create', data);
  }

  @Get()
  async listSalesOrders() {
    return await sendKafkaMessage(this.inventoryClient, 'inventory.sale.list', {});
  }
}
