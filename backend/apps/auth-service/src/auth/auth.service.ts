import {
  Injectable,
  UnauthorizedException,
  ConflictException,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcryptjs';
import { UserEntity, UserRole } from './user.entity';
import { LoginDto } from './dto/login.dto';
import { RegisterDto } from './dto/register.dto';

@Injectable()
export class AuthService {
  constructor(
    @InjectRepository(UserEntity)
    private readonly userRepository: Repository<UserEntity>,
    private readonly jwtService: JwtService,
  ) {}

  // ============================================================
  // ĐĂNG KÝ - Tạo tài khoản mới
  // ============================================================
  async register(dto: RegisterDto): Promise<{ message: string; userId: string }> {
    // Kiểm tra email đã tồn tại chưa
    const existing = await this.userRepository.findOne({ where: { email: dto.email } });
    if (existing) {
      throw new ConflictException(`Email "${dto.email}" đã được đăng ký, vui lòng dùng email khác!`);
    }

    // Hash mật khẩu với bcrypt (saltRounds = 12)
    const passwordHash = await bcrypt.hash(dto.password, 12);

    // Tạo và lưu user mới vào PostgreSQL
    const newUser = this.userRepository.create({
      fullName: dto.fullName,
      email: dto.email,
      passwordHash,
      role: dto.role ?? UserRole.CUSTOMER,
    });

    const savedUser = await this.userRepository.save(newUser);
    console.log(`✅ [Auth Service] Đã tạo tài khoản mới: ${savedUser.email}`);

    return {
      message: 'Đăng ký tài khoản thành công!',
      userId: savedUser.id,
    };
  }

  // ============================================================
  // ĐĂNG NHẬP - Xác thực và cấp JWT Token
  // ============================================================
  async login(dto: LoginDto): Promise<{
    access_token: string;
    user: { id: string; email: string; fullName: string; role: string };
  }> {
    // Bước 1: Tìm user trong database theo email
    const user = await this.userRepository.findOne({ where: { email: dto.email } });
    if (!user) {
      throw new UnauthorizedException('Email hoặc mật khẩu không chính xác!');
    }

    // Bước 2: Kiểm tra tài khoản có đang active không
    if (!user.isActive) {
      throw new UnauthorizedException('Tài khoản đã bị vô hiệu hóa, vui lòng liên hệ quản trị viên!');
    }

    // Bước 3: So sánh mật khẩu nhập vào với hash trong database
    const isPasswordValid = await bcrypt.compare(dto.password, user.passwordHash);
    if (!isPasswordValid) {
      throw new UnauthorizedException('Email hoặc mật khẩu không chính xác!');
    }

    // Bước 4: Tạo JWT Payload và ký token
    const payload = {
      sub: user.id,          // subject: user ID
      email: user.email,
      role: user.role,
      fullName: user.fullName,
    };

    const access_token = this.jwtService.sign(payload);
    console.log(`✅ [Auth Service] Đăng nhập thành công: ${user.email} (${user.role})`);

    return {
      access_token,
      user: {
        id: user.id,
        email: user.email,
        fullName: user.fullName,
        role: user.role,
      },
    };
  }

  // ============================================================
  // XÁC MINH TOKEN - Dùng trong JWT Guard
  // ============================================================
  async validateToken(token: string): Promise<any> {
    try {
      return this.jwtService.verify(token);
    } catch {
      throw new UnauthorizedException('Token không hợp lệ hoặc đã hết hạn!');
    }
  }

  // ============================================================
  // LẤY THÔNG TIN USER THEO ID - Dùng cho profile endpoint
  // ============================================================
  async getUserById(id: string): Promise<Omit<UserEntity, 'passwordHash'>> {
    const user = await this.userRepository.findOne({ where: { id } });
    if (!user) {
      throw new NotFoundException(`Không tìm thấy tài khoản!`);
    }
    // Không trả về passwordHash
    const { passwordHash, ...result } = user;
    return result;
  }
}
