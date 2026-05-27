import { NestFactory } from '@nestjs/core';
import { MicroserviceOptions, Transport } from '@nestjs/microservices';
import { AuthServiceAppModule } from './app.module';

async function bootstrap() {
  /**
   * Auth Service khởi động như một NestJS MICROSERVICE
   * Không lắng nghe HTTP — chỉ lắng nghe message từ Kafka Broker
   */
  const app = await NestFactory.createMicroservice<MicroserviceOptions>(
    AuthServiceAppModule,
    {
      transport: Transport.KAFKA,
      options: {
        client: {
          clientId: 'auth-service',
          brokers: (process.env.KAFKA_BROKERS || 'localhost:9092').split(','),
        },
        consumer: {
          // Consumer Group ID — tất cả các pod cùng group sẽ chia nhau xử lý message
          groupId: process.env.KAFKA_GROUP_ID || 'wdp301-consumers',
        },
      },
    },
  );

  await app.listen();
  console.log('🚀 Auth Microservice đang lắng nghe Kafka trên localhost:9092');
  console.log('📋 Các Topic đang lắng nghe:');
  console.log('   ✅ auth.login              (Request-Response)');
  console.log('   ✅ auth.register           (Request-Response)');
  console.log('   ✅ auth.validate.token     (Request-Response)');
  console.log('   ✅ auth.get.user.by.id     (Request-Response)');
  console.log('   ✅ auth.event.logout       (Event-Driven)');
}

bootstrap();
