import express from 'express';
import {
  signup,
  login,
  googleAuth,
  getMe,
  logout,
  changePassword,
  updateProfile,
  updateEmail,
  updateSettings,
  getSettings
} from '../controllers/authController.js';
import { protect } from '../middleware/auth.js';

const router = express.Router();

// Public routes
router.post('/signup', signup);
router.post('/login', login);
router.post('/google', googleAuth);

// Protected routes
router.get('/me', protect, getMe);
router.post('/logout', protect, logout);
router.put('/change-password', protect, changePassword);
router.put('/profile', protect, updateProfile);
router.put('/email', protect, updateEmail);
router.put('/settings', protect, updateSettings);
router.get('/settings', protect, getSettings);

export default router;
