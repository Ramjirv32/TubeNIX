import express from 'express';
import { protect } from '../middleware/auth.js';
import {
  generateThumbnail,
  generateMultipleThumbnails,
  downloadThumbnail,
  getUserThumbnails,
  getPublicThumbnails,
  getThumbnailById,
  toggleThumbnailPublic,
  generateThumbnailDemo,
  generateMultipleThumbnailsDemo
} from '../controllers/thumbnailController.js';

const router = express.Router();

// Generate single thumbnail (requires auth)
router.post('/generate', protect, generateThumbnail);

// Demo thumbnail generation (no auth required for testing)
router.post('/generate-demo', generateThumbnailDemo);

// Demo multiple thumbnail generation (no auth required for testing)
router.post('/generate-multiple-demo', generateMultipleThumbnailsDemo);

// Generate multiple thumbnails (requires auth)
router.post('/generate-multiple', protect, generateMultipleThumbnails);

// Get user's thumbnails (requires auth)
router.get('/my-thumbnails', protect, getUserThumbnails);

// Get public thumbnails (no auth required)
router.get('/public', getPublicThumbnails);

// Get specific thumbnail by ID (auth optional, depends on public status)
router.get('/:id', getThumbnailById);

// Download thumbnail (requires auth or public)
router.get('/:id/download', protect, downloadThumbnail);

// Toggle public status (requires auth and ownership)
router.patch('/:id/toggle-public', protect, toggleThumbnailPublic);

export default router;