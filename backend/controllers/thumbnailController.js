import geminiService from '../services/geminiService.js';
import huggingFaceService from '../services/huggingFaceService.js';
import UserThumbnail from '../models/UserThumbnail.js';
import Collection from '../models/Collection.js';
import fs from 'fs';
import path from 'path';

export const generateThumbnail = async (req, res, next) => {
  try {
    const { prompt, saveToCollection = false, makePublic = false } = req.body;
    
    // Check if user is authenticated
    if (!req.user || !req.user.id) {
      return res.status(401).json({
        success: false,
        message: 'Authentication required. Please log in first.'
      });
    }
    
    const userId = req.user.id;
    const userEmail = req.user.email;

    if (!prompt || prompt.trim().length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Prompt is required'
      });
    }

    if (!huggingFaceService.isPromptSafe(prompt)) {
      return res.status(400).json({
        success: false,
        message: 'Prompt contains inappropriate content'
      });
    }

    console.log(`🎨 Generating thumbnail for user ${userEmail}: ${prompt}`);

    // Use Hugging Face service instead of Gemini
    const result = await huggingFaceService.generateThumbnail(prompt);

    if (!result.success) {
      return res.status(500).json({
        success: false,
        message: result.message
      });
    }

    // Save to UserThumbnail collection
    const userThumbnail = new UserThumbnail({
      userEmail,
      userId,
      prompt: result.data.prompt,
      originalPrompt: result.data.originalPrompt,
      base64Image: result.data.base64,
      imageSize: result.data.size,
      textResponse: result.data.model || 'FLUX.1-dev',
      isPublic: makePublic,
      metadata: {
        model: result.data.model || 'FLUX.1-dev',
        generatedAt: new Date(result.data.generatedAt),
        dimensions: result.data.dimensions || '1024x576',
        fromCache: result.data.fromCache || false
      }
    });

    await userThumbnail.save();
    console.log('✅ Saved to UserThumbnail collection');

    // Optionally save to Collections as well
    if (saveToCollection) {
      const collection = new Collection({
        user: userId,
        title: `AI Generated: ${result.data.originalPrompt}`,
        description: `Generated using Hugging Face FLUX.1-dev: ${result.data.prompt}`,
        imageUrl: `data:image/png;base64,${result.data.base64}`,
        base64Image: result.data.base64,
        source: 'ai-generated',
        type: 'ai-thumbnail',
        isPublic: makePublic,
        metadata: {
          aiModel: result.data.model || 'FLUX.1-dev',
          originalPrompt: result.data.originalPrompt,
          enhancedPrompt: result.data.prompt,
          generatedAt: result.data.generatedAt,
          dimensions: result.data.dimensions || '1024x576'
        }
      });

      await collection.save();
      console.log('✅ Saved to Collections');
    }

    res.status(201).json({
      success: true,
      message: 'Thumbnail generated successfully',
      data: {
        id: userThumbnail._id,
        base64: result.data.base64,
        prompt: result.data.originalPrompt,
        enhancedPrompt: result.data.prompt,
        size: result.data.size,
        isPublic: makePublic,
        savedToCollection: saveToCollection,
        createdAt: userThumbnail.createdAt
      }
    });

  } catch (error) {
    console.error('Generate thumbnail error:', error);
    next(error);
  }
};

export const generateMultipleThumbnails = async (req, res, next) => {
  try {
    const { prompt, count = 3, saveToCollection = false, makePublic = false } = req.body;
    const userId = req.user.id;
    const userEmail = req.user.email;

    if (!prompt || prompt.trim().length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Prompt is required'
      });
    }

    if (!huggingFaceService.isPromptSafe(prompt)) {
      return res.status(400).json({
        success: false,
        message: 'Prompt contains inappropriate content'
      });
    }

    console.log(`🎨 Generating ${count} thumbnails for user ${userEmail}: ${prompt}`);

    // Use Hugging Face service
    const results = await huggingFaceService.generateMultipleThumbnails(prompt, Math.min(count, 5));

    if (!results || results.length === 0) {
      return res.status(500).json({
        success: false,
        message: 'Failed to generate thumbnails'
      });
    }

    const savedThumbnails = [];

    for (const thumbnail of results) {
      const userThumbnail = new UserThumbnail({
        userEmail,
        userId,
        prompt: thumbnail.prompt,
        originalPrompt: thumbnail.originalPrompt,
        base64Image: thumbnail.base64,
        imageSize: thumbnail.size,
        textResponse: thumbnail.model || 'FLUX.1-dev',
        isPublic: makePublic,
        metadata: {
          model: thumbnail.model || 'FLUX.1-dev',
          generatedAt: new Date(thumbnail.generatedAt),
          dimensions: thumbnail.dimensions || '1024x576',
          variation: thumbnail.variation
        }
      });

      await userThumbnail.save();
      savedThumbnails.push({
        id: userThumbnail._id,
        base64: thumbnail.base64,
        size: thumbnail.size,
        variation: thumbnail.variation,
      });

      // Save to collection if requested
      if (saveToCollection) {
        const collection = new Collection({
          user: userId,
          title: `AI Generated V${thumbnail.variation}: ${thumbnail.originalPrompt}`,
          description: `Generated using Hugging Face FLUX.1-dev: ${thumbnail.prompt}`,
          imageUrl: `data:image/png;base64,${thumbnail.base64}`,
          base64Image: thumbnail.base64,
          source: 'ai-generated',
          type: 'ai-thumbnail',
          isPublic: makePublic,
          metadata: {
            aiModel: thumbnail.model || 'FLUX.1-dev',
            originalPrompt: thumbnail.originalPrompt,
            enhancedPrompt: thumbnail.prompt,
            generatedAt: thumbnail.generatedAt,
            variation: thumbnail.variation,
            dimensions: thumbnail.dimensions || '1024x576'
          }
        });

        await collection.save();
      }
    }

    res.status(201).json({
      success: true,
      message: `Generated ${savedThumbnails.length} thumbnails successfully`,
      data: {
        thumbnails: savedThumbnails,
        prompt: prompt,
        count: savedThumbnails.length,
        savedToCollection: saveToCollection,
        isPublic: makePublic,
      }
    });

  } catch (error) {
    console.error('Generate multiple thumbnails error:', error);
    next(error);
  }
};

export const downloadThumbnail = async (req, res, next) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    const thumbnail = await UserThumbnail.findOne({ 
      _id: id, 
      $or: [{ userId }, { isPublic: true }] 
    });

    if (!thumbnail) {
      return res.status(404).json({
        success: false,
        message: 'Thumbnail not found or access denied'
      });
    }

    // Update download count
    thumbnail.downloadCount += 1;
    thumbnail.isDownloaded = true;
    await thumbnail.save();

    const imageBuffer = Buffer.from(thumbnail.base64Image, 'base64');
    const filename = `tubenix-thumbnail-${id}-${Date.now()}.png`;

    res.set({
      'Content-Type': 'image/png',
      'Content-Disposition': `attachment; filename="${filename}"`,
      'Content-Length': imageBuffer.length,
    });

    res.send(imageBuffer);

  } catch (error) {
    console.error('Download thumbnail error:', error);
    next(error);
  }
};

export const getUserThumbnails = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const { includePrivate = 'true', page = 1, limit = 20 } = req.query;

    const pageNum = Math.max(1, parseInt(page));
    const limitNum = Math.min(50, Math.max(1, parseInt(limit)));
    const skip = (pageNum - 1) * limitNum;

    const query = includePrivate === 'true' 
      ? { userId } 
      : { userId, isPublic: true };

    const thumbnails = await UserThumbnail.find(query)
      .select('-base64Image') // Exclude base64 for list view
      .sort({ createdAt: -1 })
      .limit(limitNum)
      .skip(skip);

    const total = await UserThumbnail.countDocuments(query);

    res.json({
      success: true,
      data: {
        thumbnails,
        pagination: {
          page: pageNum,
          limit: limitNum,
          total,
          pages: Math.ceil(total / limitNum),
        }
      }
    });

  } catch (error) {
    console.error('Get user thumbnails error:', error);
    next(error);
  }
};

export const getPublicThumbnails = async (req, res, next) => {
  try {
    const { page = 1, limit = 20 } = req.query;

    const pageNum = Math.max(1, parseInt(page));
    const limitNum = Math.min(50, Math.max(1, parseInt(limit)));
    const skip = (pageNum - 1) * limitNum;

    const thumbnails = await UserThumbnail.getPublicThumbnails(limitNum, skip);
    const total = await UserThumbnail.countDocuments({ isPublic: true });

    res.json({
      success: true,
      data: {
        thumbnails,
        pagination: {
          page: pageNum,
          limit: limitNum,
          total,
          pages: Math.ceil(total / limitNum),
        }
      }
    });

  } catch (error) {
    console.error('Get public thumbnails error:', error);
    next(error);
  }
};

export const getThumbnailById = async (req, res, next) => {
  try {
    const { id } = req.params;
    const userId = req.user?.id;

    // Allow access if user owns it or if it's public
    const query = userId 
      ? { _id: id, $or: [{ userId }, { isPublic: true }] }
      : { _id: id, isPublic: true };

    const thumbnail = await UserThumbnail.findOne(query);

    if (!thumbnail) {
      return res.status(404).json({
        success: false,
        message: 'Thumbnail not found or access denied'
      });
    }

    res.json({
      success: true,
      data: thumbnail
    });

  } catch (error) {
    console.error('Get thumbnail by ID error:', error);
    next(error);
  }
};

export const toggleThumbnailPublic = async (req, res, next) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    const thumbnail = await UserThumbnail.findOne({ _id: id, userId });

    if (!thumbnail) {
      return res.status(404).json({
        success: false,
        message: 'Thumbnail not found'
      });
    }

    await thumbnail.togglePublic();

    res.json({
      success: true,
      message: `Thumbnail is now ${thumbnail.isPublic ? 'public' : 'private'}`,
      data: {
        id: thumbnail._id,
        isPublic: thumbnail.isPublic,
      }
    });

  } catch (error) {
    console.error('Toggle thumbnail public error:', error);
    next(error);
  }
};

// Demo endpoint for testing without authentication
export const generateThumbnailDemo = async (req, res, next) => {
  try {
    const { prompt } = req.body;

    if (!prompt || prompt.trim().length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Prompt is required'
      });
    }

    console.log(`Demo thumbnail generation for prompt: ${prompt}`);

    // Since Gemini API has quota issues, return a demo response
    const demoBase64 = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg=='; // 1x1 red pixel

    res.status(201).json({
      success: true,
      message: 'Demo thumbnail generated successfully',
      data: {
        id: 'demo-' + Date.now(),
        base64: demoBase64,
        prompt: prompt,
        enhancedPrompt: `Enhanced: Create a high quality YouTube thumbnail for: ${prompt}`,
        size: '1 KB',
        isPublic: false,
        savedToCollection: false,
        createdAt: new Date().toISOString(),
        note: 'This is a demo response. Actual Gemini API integration requires quota.'
      }
    });

  } catch (error) {
    console.error('Demo thumbnail generation error:', error);
    next(error);
  }
};

// Demo endpoint for multiple thumbnail generation
export const generateMultipleThumbnailsDemo = async (req, res, next) => {
  try {
    const { prompt, count = 3 } = req.body;

    if (!prompt || prompt.trim().length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Prompt is required'
      });
    }

    console.log(`Demo multiple thumbnail generation for prompt: ${prompt}, count: ${count}`);

    // Generate multiple demo thumbnails with different styles
    const demoThumbnails = [];
    const styles = ['modern', 'colorful', 'minimalist', 'bold', 'playful'];
    
    for (let i = 0; i < Math.min(count, 5); i++) {
      // Different demo images (still 1x1 pixels but different colors)
      const colors = ['FF0000', '00FF00', '0000FF', 'FFFF00', 'FF00FF'];
      const colorHex = colors[i % colors.length];
      
      // Simple 1x1 colored pixel in base64 (different colors for variety)
      const demoBase64 = `iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8/5+hHgAHggJ/PchI7wAAAABJRU5ErkJggg==`;
      
      demoThumbnails.push({
        id: `demo-multiple-${Date.now()}-${i + 1}`,
        base64: demoBase64,
        size: '1 KB',
        variation: i + 1,
        style: styles[i % styles.length],
      });
    }

    res.status(201).json({
      success: true,
      message: `Generated ${demoThumbnails.length} demo thumbnails successfully`,
      data: {
        thumbnails: demoThumbnails,
        prompt: prompt,
        count: demoThumbnails.length,
        savedToCollection: false,
        isPublic: false,
        note: 'These are demo responses. Actual Gemini API integration requires quota.'
      }
    });

  } catch (error) {
    console.error('Demo multiple thumbnail generation error:', error);
    next(error);
  }
};