// config/db.ts
import mongoose from 'mongoose';

export const connectDB = async (): Promise<void> => {
  try {
    const MONGO_URI = process.env.MONGO_URI;
    if (!MONGO_URI) throw new Error('Missing MONGO_URI in .env');

    await mongoose.connect(MONGO_URI, {
      dbName: 'your-db-name', // optional
    });

    console.log('✅ MongoDB connected');
  } catch (error) {
    console.error('❌ DB connection failed:', error);
    process.exit(1);
  }
};
