import mongoose from 'mongoose';
import Collection from '../models/Collection.js';
import redisService from '../services/redisService.js';

// Get user's collections
export const getCollections = async (req, res) => {
  try {
    const userId = req.user?.id;
    const { type } = req.query;

    // If no authenticated user, return all collections (for testing without auth)
    const query = userId ? { user: userId } : {};
    if (type) {
      query.type = type;
    }

    console.log('🔍 Fetching collections with query:', JSON.stringify(query));
    const collections = await Collection.find(query).sort({ createdAt: -1 });
    console.log('📊 Found collections:', collections.length);
    
    res.json(collections);
  } catch (error) {
    console.error('Error in getCollections:', error);
    res.status(500).json({ message: 'Server error while fetching collections' });
  }
};

// Save to collection
export const saveToCollection = async (req, res, next) => {
  try {
    console.log('📥 Save to Collection Request Body:', JSON.stringify(req.body, null, 2));
    
    const { title, imageUrl, description, source, type, metadata, tags } = req.body;
    
    // Use authenticated user ID or a consistent anonymous ID for testing
    const userId = req.user?.id || new mongoose.Types.ObjectId('000000000000000000000000'); // Fixed anonymous ID
    const userEmail = req.user?.email || 'anonymous@test.com';

    console.log('📊 Extracted data:', { title, imageUrl, description, source, type });
    console.log('👤 User ID:', userId);

    if (!title || !imageUrl) {
      console.log('❌ Validation failed - Missing title or imageUrl:', { title, imageUrl });
      return res.status(400).json({
        success: false,
        message: 'Title and image URL are required',
      });
    }

    const collection = new Collection({
      user: userId,
      title,
      description,
      imageUrl,
      source: source || 'serp',
      type: type || 'image',
      metadata,
      tags,
      isLiked: false,
      isSaved: true,
    });

    await collection.save();

    // Invalidate user's collections cache
    await redisService.invalidateUserCollections(userId);

    res.status(201).json({
      message: 'Saved to collection successfully',
      collection,
    });
  } catch (error) {
    console.error('Error in saveToCollection:', error);
    res.status(500).json({ message: 'Server error while saving to collection' });
  }
};

// Toggle like
export const toggleLike = async (req, res) => {
  try {
    const userId = req.user?.id;
    const { id } = req.params;

    const query = userId ? { _id: id, user: userId } : { _id: id };
    const collection = await Collection.findOne(query);

    if (!collection) {
      return res.status(404).json({ message: 'Collection item not found' });
    }

    collection.isLiked = !collection.isLiked;
    await collection.save();

    res.json({
      message: collection.isLiked ? 'Liked' : 'Unliked',
      collection,
    });
  } catch (error) {
    console.error('Error in toggleLike:', error);
    res.status(500).json({ message: 'Server error while toggling like' });
  }
};

// Delete from collection
export const deleteFromCollection = async (req, res) => {
  try {
    const userId = req.user?.id;
    const { id } = req.params;

    // If authenticated, filter by user. Otherwise, allow deletion of any collection (for testing)
    const query = userId ? { _id: id, user: userId } : { _id: id };
    const collection = await Collection.findOneAndDelete(query);

    if (!collection) {
      return res.status(404).json({ message: 'Collection item not found' });
    }

    console.log('🗑️ Deleted collection:', id);
    res.json({ message: 'Deleted from collection successfully' });
  } catch (error) {
    console.error('Error in deleteFromCollection:', error);
    res.status(500).json({ message: 'Server error while deleting from collection' });
  }
};

// Get collection by ID
export const getCollectionById = async (req, res) => {
  try {
    const userId = req.user?.id;
    const { id } = req.params;

    const query = userId ? { _id: id, user: userId } : { _id: id };
    const collection = await Collection.findOne(query);

    if (!collection) {
      return res.status(404).json({ message: 'Collection item not found' });
    }

    res.json(collection);
  } catch (error) {
    console.error('Error in getCollectionById:', error);
    res.status(500).json({ message: 'Server error while fetching collection item' });
  }
};

// Update collection item
export const updateCollection = async (req, res) => {
  try {
    const userId = req.user?.id;
    const { id } = req.params;
    const updates = req.body;

    const query = userId ? { _id: id, user: userId } : { _id: id };
    const collection = await Collection.findOneAndUpdate(
      query,
      { $set: updates },
      { new: true }
    );

    if (!collection) {
      return res.status(404).json({ message: 'Collection item not found' });
    }

    res.json({
      message: 'Collection updated successfully',
      collection,
    });
  } catch (error) {
    console.error('Error in updateCollection:', error);
    res.status(500).json({ message: 'Server error while updating collection' });
  }
};
