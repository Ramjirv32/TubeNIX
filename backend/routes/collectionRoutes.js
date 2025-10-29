import express from 'express';
import {
  getCollections,
  saveToCollection,
  toggleLike,
  deleteFromCollection,
  getCollectionById,
  updateCollection,
} from '../controllers/collectionController.js';
// import { protect } from '../middleware/auth.js'; // Temporarily removed

const router = express.Router();

// Collection routes (middleware temporarily removed for testing)
router.get('/', getCollections);
router.post('/', saveToCollection);
router.get('/:id', getCollectionById);
router.put('/:id', updateCollection);
router.delete('/:id', deleteFromCollection);
router.post('/:id/like', toggleLike);

export default router;
