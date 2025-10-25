import serpService from '../services/serpService.js';

// Get trending videos
export const getTrendingVideos = async (req, res, next) => {
  try {
    const { query } = req.query;
    console.log('Controller: getTrendingVideos called with query:', query);
    const result = await serpService.getTrendingVideos(query);
    
    console.log('Controller: Result success:', result.success);
    if (result.success) {
      console.log('Controller: Sending', result.data.length, 'videos');
      res.json(result.data);
    } else {
      console.log('Controller: No results found:', result.message);
      res.status(404).json({ message: result.message });
    }
  } catch (error) {
    console.error('Error in getTrendingVideos:', error);
    res.status(500).json({ 
      message: 'Server error while fetching trending videos',
      error: error.message 
    });
  }
};

// Search videos
export const searchVideos = async (req, res, next) => {
  try {
    const { q } = req.query;
    
    if (!q) {
      return res.status(400).json({ message: 'Search query is required' });
    }

    const result = await serpService.searchVideos(q);
    
    if (result.success) {
      res.json(result.data);
    } else {
      res.status(404).json({ message: result.message });
    }
  } catch (error) {
    console.error('Error in searchVideos:', error);
    res.status(500).json({ message: 'Server error while searching videos' });
  }
};

// Get trending images
export const getTrendingImages = async (req, res, next) => {
  try {
    const { query } = req.query;
    const result = await serpService.getTrendingImages(query);
    
    if (result.success) {
      res.json(result.data);
    } else {
      res.status(404).json({ message: result.message });
    }
  } catch (error) {
    console.error('Error in getTrendingImages:', error);
    res.status(500).json({ message: 'Server error while fetching trending images' });
  }
};

// Search images
export const searchImages = async (req, res, next) => {
  try {
    const { q } = req.query;
    
    if (!q) {
      return res.status(400).json({ message: 'Search query is required' });
    }

    const result = await serpService.searchImages(q);
    
    if (result.success) {
      res.json(result.data);
    } else {
      res.status(404).json({ message: result.message });
    }
  } catch (error) {
    console.error('Error in searchImages:', error);
    res.status(500).json({ message: 'Server error while searching images' });
  }
};

// Get chat suggestions
export const getChatSuggestions = async (req, res, next) => {
  try {
    const { q } = req.query;
    
    if (!q) {
      return res.status(400).json({ message: 'Query is required' });
    }

    const result = await serpService.getChatSuggestions(q);
    
    if (result.success) {
      res.json(result.data);
    } else {
      res.status(404).json({ message: result.message });
    }
  } catch (error) {
    console.error('Error in getChatSuggestions:', error);
    res.status(500).json({ message: 'Server error while getting suggestions' });
  }
};
