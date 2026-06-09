import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { MedicineController } from './medicine.controller';
import { MedicineService } from './medicine.service';
import { Medicine, MedicineSchema } from './schemas/medicine.schema';
import { MedicineBatch, MedicineBatchSchema } from './schemas/medicine-batch.schema';

@Module({
  imports: [
    MongooseModule.forFeature([
      { name: Medicine.name, schema: MedicineSchema },
      { name: MedicineBatch.name, schema: MedicineBatchSchema },
    ]),
  ],
  controllers: [MedicineController],
  providers: [MedicineService],
  exports: [MongooseModule], // Export MongooseModule so other modules can use Medicine/MedicineBatch models
})
export class MedicineModule {}
