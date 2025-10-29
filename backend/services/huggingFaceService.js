import fetch from 'node-fetch';
import redisService from './redisService.js';

class HuggingFaceService {
  constructor() {
    this.apiKey = process.env.HUGGINGFACE_API_KEY;
    if (!this.apiKey) {
      console.error('⚠️ HUGGINGFACE_API_KEY not found in environment variables');
    }
    this.modelUrl = 'https://api-inference.huggingface.co/models/black-forest-labs/FLUX.1-dev';
  }

  /**
   * Generate thumbnail image using Hugging Face FLUX.1-dev model
   * @param {string} prompt - Text description for the image
   * @returns {Promise<{success: boolean, data?: {base64: string, prompt: string, buffer: Buffer}, message?: string}>}
   */
  async generateThumbnail(prompt) {
    try {
      console.log('🎨 Generating thumbnail with Hugging Face FLUX.1-dev:', prompt);
      
      // Check Redis cache first
      const cacheKey = `hf_thumbnail:${prompt}`;
      const cachedResult = await redisService.get(cacheKey);
      
      if (cachedResult) {
        console.log('✅ Found cached thumbnail for prompt');
        const parsed = JSON.parse(cachedResult);
        return {
          success: true,
          data: {
            ...parsed,
            fromCache: true
          }
        };
      }

      // Enhance prompt for better thumbnail results
      const enhancedPrompt = this.enhancePromptForThumbnail(prompt);
      console.log('📝 Enhanced prompt:', enhancedPrompt);

      // Call Hugging Face API
      const response = await fetch(this.modelUrl, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${this.apiKey}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ 
          inputs: enhancedPrompt,
          parameters: {
            guidance_scale: 7.5,
            num_inference_steps: 30,
            width: 1024,
            height: 576, // 16:9 aspect ratio for YouTube thumbnails
          }
        }),
      });

      if (!response.ok) {
        const errorText = await response.text();
        console.error('❌ Hugging Face API error:', response.status, errorText);
        
        // Check if model is loading
        if (response.status === 503) {
          throw new Error('Model is loading, please try again in a moment');
        }
        
        throw new Error(`HTTP error! status: ${response.status} - ${errorText}`);
      }

      // Get image as buffer
      const arrayBuffer = await response.arrayBuffer();
      const buffer = Buffer.from(arrayBuffer);
      
      // Convert to base64
      const base64Image = buffer.toString('base64');
      
      console.log('✅ Thumbnail generated successfully, size:', Math.round(base64Image.length / 1024), 'KB');

      const resultData = {
        base64: base64Image,
        buffer: buffer,
        prompt: enhancedPrompt,
        originalPrompt: prompt,
        generatedAt: new Date().toISOString(),
        size: Math.round(base64Image.length / 1024) + ' KB',
        model: 'FLUX.1-dev',
        dimensions: '1024x576'
      };

      // Cache the result for 24 hours (excluding buffer for storage efficiency)
      const cacheData = {
        base64: base64Image,
        prompt: enhancedPrompt,
        originalPrompt: prompt,
        generatedAt: resultData.generatedAt,
        size: resultData.size,
        model: resultData.model,
        dimensions: resultData.dimensions
      };
      
      await redisService.setex(cacheKey, 86400, JSON.stringify(cacheData)); // 24 hours
      console.log('💾 Cached thumbnail result');

      return {
        success: true,
        data: resultData
      };

    } catch (error) {
      console.error('❌ Hugging Face Service Error:', error.message);
      return {
        success: false,
        message: error.message || 'Failed to generate thumbnail with Hugging Face'
      };
    }
  }

  /**
   * Enhance user prompt to generate better thumbnails
   * @param {string} userPrompt 
   * @returns {string}
   */
  enhancePromptForThumbnail(userPrompt) {
    // Check if it's already well-formatted
    if (userPrompt.toLowerCase().includes('youtube thumbnail') || 
        userPrompt.toLowerCase().includes('high quality') ||
        userPrompt.length > 100) {
      return userPrompt;
    }

    // Enhance for YouTube thumbnail quality
    return `Professional YouTube thumbnail for: ${userPrompt}. High quality, vibrant colors, eye-catching design, bold text overlay, 16:9 aspect ratio, photorealistic, trending style, engaging composition`;
  }

  /**
   * Generate multiple thumbnail variations
   * @param {string} prompt 
   * @param {number} count 
   * @returns {Promise<Array>}
   */
  async generateMultipleThumbnails(prompt, count = 3) {
    const results = [];
    
    for (let i = 0; i < count; i++) {
      // Add variation to the prompt
      const variationPrompt = this.addVariation(prompt, i);
      const result = await this.generateThumbnail(variationPrompt);
      
      if (result.success) {
        results.push({
          ...result.data,
          variation: i + 1
        });
      } else {
        console.warn(`Failed to generate variation ${i + 1}:`, result.message);
      }
      
      // Add small delay between requests to avoid rate limiting
      if (i < count - 1) {
        await new Promise(resolve => setTimeout(resolve, 1000));
      }
    }
    
    return results;
  }

  /**
   * Add variation to prompt for different results
   * @param {string} prompt 
   * @param {number} index 
   * @returns {string}
   */
  addVariation(prompt, index) {
    const variations = [
      'Style 1: Modern and clean design',
      'Style 2: Bold and dramatic with high contrast',
      'Style 3: Colorful and energetic composition'
    ];
    
    return `${prompt}. ${variations[index % variations.length]}`;
  }

  /**
   * Check if prompt is safe (basic content filtering)
   * @param {string} prompt 
   * @returns {boolean}
   */
  isPromptSafe(prompt) {
    const inappropriateKeywords = [
      'nude', 'naked', 'nsfw', 'porn', 'sex',
      'violence', 'gore', 'blood', 'death',
      'hate', 'racist', 'terrorism'
    ];
    
    const lowerPrompt = prompt.toLowerCase();
    return !inappropriateKeywords.some(keyword => lowerPrompt.includes(keyword));
  }

  /**
   * Clear cache for a specific prompt
   * @param {string} prompt 
   */
  async clearCache(prompt) {
    const cacheKey = `hf_thumbnail:${prompt}`;
    await redisService.del(cacheKey);
    console.log('🗑️ Cleared cache for prompt:', prompt);
  }

  /**
   * Get cache statistics
   */
  async getCacheStats() {
    const keys = await redisService.keys('hf_thumbnail:*');
    return {
      totalCached: keys ? keys.length : 0,
      cachePrefix: 'hf_thumbnail:',
      ttl: '24 hours'
    };
  }
}

export default new HuggingFaceService();
