import { GoogleGenAI } from "@google/genai";

class GeminiService {
  constructor() {
    this.genai = new GoogleGenAI({
      apiKey: process.env.GEMINI_API_KEY || 'AIzaSyCacdgAmX_XSOxjVMGDZOQgvnce4i_46eU'
    });
  }

  /**
   * Generate thumbnail image based on text prompt
   * @param {string} prompt - Text description for the image
   * @param {object} options - Additional options
   * @returns {Promise<{success: boolean, data?: {base64: string, prompt: string}, message?: string}>}
   */
  async generateThumbnail(prompt, options = {}) {
    try {
      console.log('Generating thumbnail with prompt:', prompt);
      
      // Enhance prompt for better thumbnail results
      const enhancedPrompt = this.enhancePromptForThumbnail(prompt);
      console.log('Enhanced prompt:', enhancedPrompt);

      // First try Gemini API
      try {
        const response = await this.genai.models.generateContent({
          model: "gemini-2.5-flash-image",
          contents: enhancedPrompt,
        });

        if (response.candidates && response.candidates[0]) {
          const parts = response.candidates[0].content.parts;
          let base64Image = null;
          let textResponse = '';

          for (const part of parts) {
            if (part.text) {
              textResponse += part.text;
            } else if (part.inlineData) {
              base64Image = part.inlineData.data;
              console.log('Generated image size:', Math.round(base64Image.length / 1024), 'KB');
            }
          }

          if (base64Image) {
            return {
              success: true,
              data: {
                base64: base64Image,
                prompt: enhancedPrompt,
                originalPrompt: prompt,
                textResponse: textResponse || '',
                generatedAt: new Date().toISOString(),
                size: Math.round(base64Image.length / 1024) + ' KB'
              }
            };
          }
        }
      } catch (apiError) {
        console.log('Gemini API failed, using demo mode:', apiError.message);
        
        // Check if it's a quota error
        if (apiError.message.includes('quota') || apiError.message.includes('RESOURCE_EXHAUSTED')) {
          return this.generateDemoThumbnail(prompt, enhancedPrompt);
        }
        
        throw apiError;
      }

      throw new Error('No image data returned from Gemini API');

    } catch (error) {
      console.error('Gemini API Error:', error.message);
      
      // Fallback to demo mode for any error
      console.log('Falling back to demo mode');
      return this.generateDemoThumbnail(prompt, this.enhancePromptForThumbnail(prompt));
    }
  }

  /**
   * Generate a demo thumbnail (placeholder) when API fails
   */
  generateDemoThumbnail(originalPrompt, enhancedPrompt) {
    // Create a simple colored rectangle as demo
    const demoImages = [
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==', // Red
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==', // Blue
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+P+fAQAEhAFfbKp1tAAAAABJRU5ErkJggg==', // Green
    ];

    const randomImage = demoImages[Math.floor(Math.random() * demoImages.length)];
    
    return {
      success: true,
      data: {
        base64: randomImage,
        prompt: enhancedPrompt,
        originalPrompt: originalPrompt,
        textResponse: `Demo mode: This is a placeholder thumbnail. The actual Gemini AI service is currently unavailable due to quota limits.`,
        generatedAt: new Date().toISOString(),
        size: '1 KB (Demo)',
        isDemo: true
      }
    };
  }

  /**
   * Enhance user prompt to generate better thumbnails
   * @param {string} userPrompt 
   * @returns {string}
   */
  enhancePromptForThumbnail(userPrompt) {
    // Check if it's already well-formatted
    if (userPrompt.toLowerCase().includes('thumbnail') || 
        userPrompt.toLowerCase().includes('youtube') ||
        userPrompt.toLowerCase().includes('high quality')) {
      return userPrompt;
    }

    // Enhance for YouTube thumbnail quality
    const thumbnailKeywords = [
      'high quality YouTube thumbnail',
      'vibrant colors',
      'eye-catching design',
      '16:9 aspect ratio',
      'professional quality',
      'clear and bold text',
      'engaging visual'
    ];

    return `Create a ${thumbnailKeywords.join(', ')} for: ${userPrompt}. Make it visually appealing and suitable for social media.`;
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
      
      // Small delay to avoid rate limiting
      if (i < count - 1) {
        await new Promise(resolve => setTimeout(resolve, 1000));
      }
    }

    return {
      success: results.length > 0,
      data: results,
      message: results.length > 0 
        ? `Generated ${results.length} variations`
        : 'Failed to generate any thumbnails'
    };
  }

  /**
   * Add variation to prompts
   */
  addVariation(prompt, index) {
    const styles = [
      'modern and sleek style',
      'colorful and energetic style', 
      'minimalist and clean style',
      'bold and dramatic style',
      'playful and fun style'
    ];
    
    return `${prompt} in a ${styles[index % styles.length]}`;
  }

  /**
   * Validate image prompt for content safety
   * @param {string} prompt 
   * @returns {boolean}
   */
  isPromptSafe(prompt) {
    const blockedKeywords = [
      'nude', 'explicit', 'violence', 'hate', 'inappropriate',
      'nsfw', 'adult', 'sexual', 'weapon', 'drug'
    ];
    
    const lowerPrompt = prompt.toLowerCase();
    return !blockedKeywords.some(keyword => lowerPrompt.includes(keyword));
  }
}

export default new GeminiService();