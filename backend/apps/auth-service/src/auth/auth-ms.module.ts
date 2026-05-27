import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { JwtModule } from '@nestjs/jwt';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { UserEntity } from './user.entity';
import { AuthService } from './auth.service';
import { AuthMsController } from './auth-ms.controller';

@Module({
  imports: [
    // TypeORM: Đăng ký UserEntity để service có thể thao tác với bảng users
    TypeOrmModule.forFeature([UserEntity]),

    // JWT: Cấu hình module ký và xác thực token
    JwtModule.registerAsync({
      imports: [ConfigModule],
      useFactory: (config: ConfigService) => ({
        secret: config.get<string>('JWT_SECRET'),
        signOptions: { expiresIn: config.get<string>('JWT_EXPIRES_IN', '3600s') },
      }),
      inject: [ConfigService],
    }),
  ],
  controllers: [AuthMsController],
  providers: [AuthService],
  exports: [AuthService],
})
export class AuthMsModule {}
