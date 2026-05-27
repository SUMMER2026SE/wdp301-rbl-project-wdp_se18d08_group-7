import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { UserEntity } from './auth/user.entity';
import { AuthMsModule } from './auth/auth-ms.module';

/**
 * Root Module của Auth Microservice
 * Kết nối Database PostgreSQL và import các sub-modules
 */
@Module({
  imports: [
    // Đọc biến môi trường từ file .env
    ConfigModule.forRoot({ isGlobal: true }),

    // Kết nối TypeORM -> PostgreSQL/Supabase
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      useFactory: (config: ConfigService) => ({
        type: 'postgres',
        url: config.get<string>('DATABASE_URL'),
        entities: [UserEntity],
        // Tự động tạo/cập nhật bảng trong DB theo định nghĩa Entity
        // QUAN TRỌNG: Chỉ dùng synchronize: true khi development!
        // Ở production phải dùng migrations.
        synchronize: config.get<string>('NODE_ENV') !== 'production',
        ssl: {
          // Supabase yêu cầu SSL
          rejectUnauthorized: false,
        },
        logging: config.get<string>('NODE_ENV') === 'development',
      }),
      inject: [ConfigService],
    }),

    AuthMsModule,
  ],
})
export class AuthServiceAppModule {}
