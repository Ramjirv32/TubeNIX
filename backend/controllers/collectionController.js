import Collection from '../models/Collection.js';

// Get user's collections
export const getCollections = async (req, res) => {
  try {
    const userId = req.user.id;
    const { type } = req.query;

    const query = { user: userId };
    if (type) {
      query.type = type;
    }

    const collections = await Collection.find(query).sort({ createdAt: -1 });
    
    res.json(collections);
  } catch (error) {
    console.error('Error in getCollections:', error);
    res.status(500).json({ message: 'Server error while fetching collections' });
  }
};

// Save to collection
export const saveToCollection = async (req, res) => {
  try {
    const userId = req.user.id;
    const { title, description, imageUrl, source, type, metadata, tags } = req.body;

    if (!title || !imageUrl) {
      return res.status(400).json({ message: 'Title and image URL are required' });
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
    const userId = req.user.id;
    const { id } = req.params;

    const collection = await Collection.findOne({ _id: id, user: userId });

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
    const userId = req.user.id;
    const { id } = req.params;

    const collection = await Collection.findOneAndDelete({ _id: id, user: userId });

    if (!collection) {
      return res.status(404).json({ message: 'Collection item not found' });
    }

    res.json({ message: 'Deleted from collection successfully' });
  } catch (error) {
    console.error('Error in deleteFromCollection:', error);
    res.status(500).json({ message: 'Server error while deleting from collection' });
  }
};

// Get collection by ID
export const getCollectionById = async (req, res) => {
  try {
    const userId = req.user.id;
    const { id } = req.params;

    const collection = await Collection.findOne({ _id: id, user: userId });

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
    const userId = req.user.id;
    const { id } = req.params;
    const updates = req.body;

    const collection = await Collection.findOneAndUpdate(
      { _id: id, user: userId },
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
