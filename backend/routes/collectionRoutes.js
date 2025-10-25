import express from 'express';
import {
  getCollections,
  saveToCollection,
  toggleLike,
  deleteFromCollection,
  getCollectionById,
  updateCollection,
} from '../controllers/collectionController.js';
import { protect } from '../middleware/auth.js';

const router = express.Router();

// Collection routes (all protected)
router.get('/', protect, getCollections);
router.post('/', protect, saveToCollection);
router.get('/:id', protect, getCollectionById);
router.put('/:id', protect, updateCollection);
router.delete('/:id', protect, deleteFromCollection);
router.post('/:id/like', protect, toggleLike);

export default router;
