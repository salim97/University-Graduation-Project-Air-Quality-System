const crypto = require('crypto');
const mongoose = require('mongoose');
const validator = require('validator');
const bcrypt = require('bcryptjs');

const userSchema = new mongoose.Schema({
  // firebaseCloudMessagingToken: String,
  // loggedAt: Date,
  // loggedWithIP: String,

  fcmToken: {
    type: String,
  },
  email: {
    type: String,
    required: [true, 'Please provide your email'],
    unique: true,
    lowercase: true,
    validate: [validator.isEmail, 'Please provide a valid email']
  },
  photo: {
    type: String,
    default: 'default.jpg'
  },
  role: {
    type: String,
    enum: ['user', 'admin', 'chakam'],
    default: 'user'
  },
 
});







const User = mongoose.model('User', userSchema);

module.exports = User;
