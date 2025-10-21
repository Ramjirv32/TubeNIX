import jwt from 'jsonwebtoken';
import { config } from '../config/config.js';

export const generateToken = (userId) => {
  return jwt.sign(
    { id: userId },
    config.jwtSecret,
    { expiresIn: config.jwtExpire }
  );
};

export const verifyToken = (token) => {
  try {
    return jwt.verify(token, config.jwtSecret);
  } catch (error) {
    throw new Error('Invalid or expired token');
  }
};
