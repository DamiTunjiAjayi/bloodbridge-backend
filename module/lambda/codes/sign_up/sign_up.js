// File: models/User.js
const mongoose = require('mongoose');
const bcrypt = require('bcrypt');

const userSchema = new mongoose.Schema({
  // Basic Info
  name: { type: String, required: true },
  dateOfBirth: { type: Date, required: true },
  phoneNumber: { type: String, unique: true, required: true },
  email: { type: String, unique: true, lowercase: true, required: true },
  gender: { 
    type: String, 
    enum: ['Male', 'Female', 'Other'], 
    required: true 
  },

  // Auth Info
  password: { type: String, required: true },
  confirmPassword: { type: String, required: true }, // can be validated before save

  // Medical Info
  bloodGroup: {
    type: String,
    enum: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'],
    required: true
  },
  genotype: {
    type: String,
    enum: ['AA', 'AS', 'SS', 'AC', 'SC'],
    required: true
  },
  medicalCondition: {
    type: String,
    enum: ['None', 'Diabetes', 'Hypertension', 'Other'],
    default: 'None',
    required: true
  },
  lastDonationDate: {
    type: String,
    enum: [
      'First Time Donor',
      '3 months ago',
      '6 months ago',
      '1 year ago',
      'More than 1 year'
    ],
    required: true
  },

  // Location Info
  currentLocation: { type: String, required: true },
  preferredDonationRadius: {
    type: String,
    enum: ['5km', '10km', '25km', '50km'],
    required: true
  },
  preferredDonationCenters: {
    type: [String],
    required: true
  },

  // Consent Checkboxes
  agreeToDonate: {
    type: Boolean,
    required: true,
    validate: {
      validator: v => v === true,
      message: 'You must agree to donate voluntarily.'
    }
  },
  allowContact: {
    type: Boolean,
    default: false
  },

  // System fields
  phoneVerified: { type: Boolean, default: false },
  phoneVerificationCode: String,
  phoneVerificationExpires: Date,
  resetPasswordToken: String,
  resetPasswordExpires: Date,
  email2FAEnabled: { type: Boolean, default: false },
  email2FACode: String,
  email2FAExpires: Date,
  lastLogin: Date,
  createdAt: { type: Date, default: Date.now }
});

// Hash password before saving
userSchema.pre('save', async function (next) {
  if (!this.isModified('password')) return next();
  const salt = await bcrypt.genSalt(10);
  this.password = await bcrypt.hash(this.password, salt);
  next();
});

// Compare entered password with hashed password
userSchema.methods.comparePassword = async function (candidatePassword) {
  return bcrypt.compare(candidatePassword, this.password);
};

module.exports = mongoose.model('User', userSchema);
