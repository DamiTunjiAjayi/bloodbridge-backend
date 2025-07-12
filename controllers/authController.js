const admin = require('../config/firebase');
const User = require('../models/User');

exports.signup = async (req, res) => {
  const { token, fullName, bloodType, location, phone, isDonor } = req.body;
  try {
    const decodedToken = await admin.auth().verifyIdToken(token);
    const existing = await User.findOne({ uid: decodedToken.uid });
    if (existing) return res.status(200).json(existing);

    const user = await User.create({
      uid: decodedToken.uid,
      email: decodedToken.email,
      fullName,
      bloodType,
      location,
      phone,
      isDonor
    });

    res.status(201).json(user);
  } catch (err) {
    console.error('Signup error:', err);
    res.status(400).json({ message: 'Invalid signup data' });
  }
};
