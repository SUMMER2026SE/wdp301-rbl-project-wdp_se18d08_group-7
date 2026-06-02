import {
  Injectable,
  UnauthorizedException,
  ConflictException,
  NotFoundException,
  InternalServerErrorException,
} from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcryptjs';
import { Pool } from 'pg';
import { User, UserRole } from './user.schema';
import { VerificationToken, TokenType } from './verification-token.schema';
import { LoginDto } from './dto/login.dto';
import { RegisterDto } from './dto/register.dto';
import * as nodemailer from 'nodemailer';

@Injectable()
export class AuthService {
  private pgPool: Pool;

  constructor(
    @InjectModel(User.name)
    private readonly userModel: Model<User>,
    @InjectModel(VerificationToken.name)
    private readonly tokenModel: Model<VerificationToken>,
    private readonly jwtService: JwtService,
  ) {
    this.pgPool = new Pool({
      connectionString: process.env.DATABASE_URL,
      ssl: { rejectUnauthorized: false }, // Cho Supabase
    });
    this.initPostgresTable();
  }

  private async initPostgresTable() {
    const query = `
      CREATE TABLE IF NOT EXISTS public.users (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        full_name VARCHAR(255) NOT NULL,
        email VARCHAR(255) UNIQUE NOT NULL,
        password_hash VARCHAR(255) NOT NULL,
        role VARCHAR(50) DEFAULT 'user',
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      );
      ALTER TABLE public.users ENABLE ROW LEVEL SECURITY; 
    `;
    try {    // để ở đây là ENABLE ROW LEVEL SECURITY là quyền hạn cao nhất cảu PostgressTable
      await this.pgPool.query(query);
      console.log('✅ [Postgres] Đã kiểm tra/tạo bảng users thành công');
    } catch (err) {
      console.error('❌ [Postgres] Lỗi tạo bảng:', err);
    }
  }

  // ============================================================
  // ĐĂNG KÝ - Tạo tài khoản mới
  // ============================================================
  async register(dto: RegisterDto): Promise<{ message: string; userId: string }> {
    if (dto.role === 'user') {
      return this.registerToPostgres(dto);
    }

    const existing = await this.userModel.findOne({ email: dto.email });
    if (existing) {
      throw new ConflictException(`Email "${dto.email}" đã được đăng ký!`);
    }

    const passwordHash = await bcrypt.hash(dto.password, 12);

    const newUser = new this.userModel({
      fullName: dto.fullName,
      email: dto.email,
      passwordHash,
      role: dto.role ?? UserRole.PHARMACIST,
    });

    const savedUser = await newUser.save();
    return {
      message: 'Đăng ký tài khoản thành công!',
      userId: savedUser._id.toString(),
    };
  }

  private async registerToPostgres(dto: RegisterDto): Promise<{ message: string; userId: string }> {
    const passwordHash = await bcrypt.hash(dto.password, 12);
    try {
      const result = await this.pgPool.query(
        'INSERT INTO public.users (full_name, email, password_hash, role) VALUES ($1, $2, $3, $4) RETURNING id',
        [dto.fullName, dto.email, passwordHash, 'user']
      );
      return {
        message: 'Đăng ký tài khoản khách hàng thành công!',
        userId: result.rows[0].id,
      };
    } catch (err: any) {
      if (err.code === '23505') { // PostgreSQL Unique Violation
        throw new ConflictException(`Email "${dto.email}" đã được đăng ký!`);
      }
      throw new InternalServerErrorException('Lỗi khi lưu dữ liệu vào PostgreSQL');
    }
  }

  // ============================================================
  // ĐĂNG NHẬP - Xác thực và cấp JWT Token

  // ============================================================
  async login(dto: LoginDto): Promise<{
    access_token: string;
    user: { id: string; email: string; fullName: string; role: string };
  }> {
    let userFromDb: any = null;
    let isPostgres = false;

    // 1. Tìm trong MongoDB trước
    const mongoUser = await this.userModel.findOne({ email: dto.email });
    if (mongoUser) {
      userFromDb = {
        id: mongoUser._id.toString(),
        email: mongoUser.email,
        passwordHash: mongoUser.passwordHash,
        role: mongoUser.role,
        fullName: mongoUser.fullName,
        isActive: mongoUser.isActive,
      };
    } else {
      // 2. Nếu không có, tìm trong Postgres
      const pgResult = await this.pgPool.query(
        'SELECT id, email, password_hash as "passwordHash", role, full_name as "fullName" FROM public.users WHERE email = $1',
        [dto.email]
      );
      if (pgResult.rows.length > 0) {
        userFromDb = pgResult.rows[0];
        userFromDb.isActive = true; // Giả định user postgres luôn active
        isPostgres = true;
      }
    }

    if (!userFromDb) {
      throw new UnauthorizedException('Email hoặc mật khẩu không chính xác!');
    }

    if (!userFromDb.isActive) {
      throw new UnauthorizedException('Tài khoản đã bị vô hiệu hóa!');
    }

    const isPasswordValid = await bcrypt.compare(dto.password, userFromDb.passwordHash);
    if (!isPasswordValid) {
      throw new UnauthorizedException('Email hoặc mật khẩu không chính xác!');
    }

    const payload = {
      sub: userFromDb.id,
      email: userFromDb.email,
      role: userFromDb.role,
      fullName: userFromDb.fullName,
    };

    const access_token = this.jwtService.sign(payload);

    return {
      access_token,
      user: {
        id: userFromDb.id,
        email: userFromDb.email,
        fullName: userFromDb.fullName,
        role: userFromDb.role,
      },
    };
  }

  // ============================================================
  // GOOGLE LOGIN
  // ============================================================
  async googleLogin(profile: any): Promise<{
    access_token: string;
    user: { id: string; email: string; fullName: string; role: string };
  }> {
    const { email, fullName } = profile;
    let userFromDb: any = null;
    let isPostgres = false;

    // 1. Tìm trong MongoDB trước
    const mongoUser = await this.userModel.findOne({ email });
    if (mongoUser) {
      userFromDb = {
        id: mongoUser._id.toString(),
        email: mongoUser.email,
        role: mongoUser.role,
        fullName: mongoUser.fullName,
        isActive: mongoUser.isActive,
      };
    } else {
      // 2. Tìm trong Postgres
      const pgResult = await this.pgPool.query(
        'SELECT id, email, role, full_name as "fullName" FROM public.users WHERE email = $1',
        [email]
      );
      if (pgResult.rows.length > 0) {
        userFromDb = pgResult.rows[0];
        userFromDb.isActive = true;
        isPostgres = true;
      }
    }

    // 3. Nếu chưa tồn tại, tự động đăng ký mới vào Postgres
    if (!userFromDb) {
      const passwordHash = await bcrypt.hash(Math.random().toString(36).slice(-10), 12); // Random password cho Google users
      const insertResult = await this.pgPool.query(
        'INSERT INTO public.users (full_name, email, password_hash, role) VALUES ($1, $2, $3, $4) RETURNING id',
        [fullName, email, passwordHash, 'user']
      );
      
      userFromDb = {
        id: insertResult.rows[0].id,
        email,
        fullName,
        role: 'user',
        isActive: true,
      };
    }

    if (!userFromDb.isActive) {
      throw new UnauthorizedException('Tài khoản đã bị vô hiệu hóa!');
    }

    // 4. Cấp JWT Token
    const payload = {
      sub: userFromDb.id,
      email: userFromDb.email,
      role: userFromDb.role,
      fullName: userFromDb.fullName,
    };

    const access_token = this.jwtService.sign(payload);

    return {
      access_token,
      user: {
        id: userFromDb.id,
        email: userFromDb.email,
        fullName: userFromDb.fullName,
        role: userFromDb.role,
      },
    };
  }

  // ============================================================
  // XÁC MINH TOKEN - Dùng trong JWT Guard
  // ============================================================
  async validateToken(token: string): Promise<any> {
    try {
      const payload = this.jwtService.verify(token);
      if (!payload) throw new UnauthorizedException('Token không hợp lệ!');
      return payload;
    } catch {
      throw new UnauthorizedException('Token không hợp lệ hoặc đã hết hạn!');
    }
  }

  // ============================================================
  // QUÊN MẬT KHẨU - Gửi mã xác nhận qua Email
  // ============================================================
  async generateAndSendResetToken(email: string): Promise<{ message: string }> {
    let userExists = false;

    const pgResult = await this.pgPool.query('SELECT id FROM public.users WHERE email = $1', [email]);
    if (pgResult.rows.length > 0) {
      userExists = true;
    } else {
      const mongoUser = await this.userModel.findOne({ email });
      if (mongoUser) {
        userExists = true;
      }
    }

    if (!userExists) {
      throw new NotFoundException(`Không tìm thấy tài khoản với email ${email}`);
    }

    const otp = Math.floor(100000 + Math.random() * 900000).toString();

    const expiresAt = new Date();
    expiresAt.setMinutes(expiresAt.getMinutes() + 5);

    await this.tokenModel.deleteMany({ userId: email, type: TokenType.PASSWORD_RESET });

    await this.tokenModel.create({
      token: otp,
      type: TokenType.PASSWORD_RESET,
      expiresAt,
      userId: email,
      isUsed: false,
    });

    try {
      if (process.env.SMTP_USER && process.env.SMTP_PASS) {
        const transporter = nodemailer.createTransport({
          service: 'gmail',
          auth: {
            user: process.env.SMTP_USER,
            pass: process.env.SMTP_PASS,
          },
        });

        await transporter.sendMail({
          from: `"VinaPharmacy" <${process.env.SMTP_USER}>`,
          to: email,
          subject: 'Mã xác nhận khôi phục mật khẩu',
          html: `
            <div style="font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif; max-width: 600px; margin: 0 auto; background-color: #ffffff; border-radius: 12px; border: 1px solid #eaeaea; overflow: hidden; box-shadow: 0 4px 12px rgba(0,0,0,0.05);">
              <div style="background-color: #0057cd; padding: 24px; text-align: center;">
                <h1 style="color: #ffffff; margin: 0; font-size: 24px; font-weight: 700; letter-spacing: 0.5px;">VinaPharmacy</h1>
              </div>
              <div style="padding: 40px 30px;">
                <h2 style="color: #1e293b; font-size: 20px; margin-top: 0; margin-bottom: 20px;">Xác nhận khôi phục mật khẩu</h2>
                <p style="color: #475569; font-size: 15px; line-height: 1.6; margin-bottom: 30px;">
                  Xin chào,<br><br>
                  Chúng tôi vừa nhận được yêu cầu khôi phục mật khẩu cho tài khoản của bạn tại <strong>VinaPharmacy</strong>. Vui lòng sử dụng mã xác nhận (OTP) dưới đây để thiết lập lại mật khẩu:
                </p>
                <div style="text-align: center; margin-bottom: 30px;">
                  <span style="display: inline-block; letter-spacing: 8px; color: #0057cd; font-size: 36px; font-weight: 900; padding: 16px 32px; background-color: #f0f8ff; border: 2px dashed #0057cd; border-radius: 12px;">${otp}</span>
                </div>
                <p style="color: #64748b; font-size: 14px; text-align: center; margin-bottom: 30px;">
                  ⏳ Mã xác nhận này sẽ tự động hết hạn sau <strong>5 phút</strong>.
                </p>
                <hr style="border: none; border-top: 1px solid #e2e8f0; margin-bottom: 20px;">
                <p style="color: #94a3b8; font-size: 13px; line-height: 1.6; margin: 0; text-align: center;">
                  Nếu bạn không thực hiện yêu cầu này, vui lòng bỏ qua email. Tài khoản của bạn vẫn được bảo mật an toàn.<br><br>
                  Trân trọng,<br>
                  <strong>Đội ngũ VinaPharmacy</strong>
                </p>
              </div>
            </div>
          `,
        });
        console.log(`✉️ [Email] Đã gửi OTP đến ${email}`);
      } else {
        console.warn(`⚠️ [MOCK EMAIL] Gửi email đến ${email}. Mã OTP: ${otp}`);
      }
    } catch (error) {
      console.error(`❌ [Email Error] Lỗi gửi mail: ${error.message}`);
    }

    return { message: 'Mã xác nhận đã được gửi đến email của bạn!' };
  }

  // ============================================================
  // ĐẶT LẠI MẬT KHẨU
  // ============================================================
  async resetPassword(email: string, token: string, newPassword: string): Promise<{ message: string }> {
    const resetToken = await this.tokenModel.findOne({
      userId: email,
      token: token,
      type: TokenType.PASSWORD_RESET,
      isUsed: false,
    });

    if (!resetToken) {
      throw new UnauthorizedException('Mã xác nhận không đúng hoặc không tồn tại!');
    }

    if (new Date() > resetToken.expiresAt) {
      throw new UnauthorizedException('Mã xác nhận đã hết hạn!');
    }

    const passwordHash = await bcrypt.hash(newPassword, 12);

    const pgResult = await this.pgPool.query('SELECT id FROM public.users WHERE email = $1', [email]);
    
    if (pgResult.rows.length > 0) {
      await this.pgPool.query(
        'UPDATE public.users SET password_hash = $1 WHERE email = $2',
        [passwordHash, email]
      );
    } else {
      const mongoUser = await this.userModel.findOne({ email });
      if (!mongoUser) {
        throw new NotFoundException('Không tìm thấy tài khoản để đổi mật khẩu');
      }
      mongoUser.passwordHash = passwordHash;
      await mongoUser.save();
    }

    resetToken.isUsed = true;
    await resetToken.save();

    return { message: 'Đổi mật khẩu thành công! Bạn có thể đăng nhập ngay bây giờ.' };
  }

  // ============================================================
  // LẤY THÔNG TIN USER THEO ID
  // ============================================================
  async getUserById(id: string): Promise<any> {
    const user = await this.userModel.findById(id).select('-passwordHash').exec();
    if (!user) {
      throw new NotFoundException(`Không tìm thấy tài khoản!`);
    }
    return user.toObject();
  }
}
