import axios from 'axios';
import redisService from './redisService.js';

const SERP_API_KEY = 'b00f765aac12f9ca8de9e619170acee8a5a298c69c372ea64fa22f6646643667';
const SERP_API_BASE_URL = 'https://serpapi.com/search';

class SerpService {
  // Get trending YouTube videos
  async getTrendingVideos(query = 'trending', location = 'United States') {
    // Check Redis cache first
    const cacheKey = `trending_videos_${query}`;
    const cachedResults = await redisService.getCachedSearchResults(cacheKey);
    if (cachedResults) {
      console.log('Returning cached trending videos');
      return cachedResults;
    }

    const attempts = 2;
    const timeout = 10000; 

    for (let attempt = 1; attempt <= attempts; attempt++) {
      try {
        const params = {
          engine: 'youtube',
          search_query: query,
          api_key: SERP_API_KEY,
          gl: 'us',
          hl: 'en',
        };

        console.log(`Fetching trending videos (attempt ${attempt}) with params:`, params);
        const response = await axios.get(SERP_API_BASE_URL, { params, timeout });
        console.log('SERP API Response Status:', response.status);
        // Defensive: ensure response.data is an object
        const data = response.data || {};
        console.log('SERP API Response Keys:', Object.keys(data));

        // Aggregate candidate video arrays from several possible locations
        let candidates = [];

        if (Array.isArray(data.video_results)) candidates = candidates.concat(data.video_results);
        if (Array.isArray(data.videos)) candidates = candidates.concat(data.videos);
        if (Array.isArray(data.organic_results)) {
          // organic_results can contain inline videos or links to youtube
          data.organic_results.forEach(item => {
            if (item.video_results && Array.isArray(item.video_results)) candidates = candidates.concat(item.video_results);
            if (item.inline_videos && Array.isArray(item.inline_videos)) candidates = candidates.concat(item.inline_videos);
            // sometimes the organic result itself looks like a video item
            if (item.link && (item.link.includes('youtube.com') || item.link.includes('youtu.be'))) candidates.push(item);
          });
        }

        // As a final fallback, check top-level 'results' or 'items'
        if (Array.isArray(data.results)) candidates = candidates.concat(data.results);
        if (Array.isArray(data.items)) candidates = candidates.concat(data.items);

        // Deduplicate by link/id
        const seen = new Set();
        const videoResults = [];
        candidates.forEach(video => {
          const key = (video.link || video.id || video.video_id || video.url || '').toString();
          if (!key) return; // skip items without any id/link
          if (!seen.has(key)) {
            seen.add(key);
            videoResults.push(video);
          }
        });

        if (videoResults.length > 0) {
          console.log('Found videos:', videoResults.length);
          const result = {
            success: true,
            data: videoResults.map(video => ({
              id: (video.link || video.video_id || video.id || video.url || '').toString(),
              title: video.title || video.name || video.snippet || 'Untitled',
              channelName: (video.channel && (video.channel.name || video.channel)) || video.uploader || video.source || 'Unknown',
              imageUrl: video.thumbnail?.static || video.thumbnail || video.image || video.thumbnailUrl || video.thumbnail_url || 'https://via.placeholder.com/320x180?text=No+Image',
              views: video.views || video.view_count || video.formatted_views || '0',
              publishedDate: video.published_date || video.published_time || video.date || 'Recently',
              duration: video.length || video.duration || video.video_length || 'N/A',
              link: video.link || video.url || '',
              description: video.description || video.snippet || '',
              type: 'video',
            })),
          };
          
          // Cache the results for 30 minutes
          await redisService.cacheSearchResults(cacheKey, result, 1800);
          return result;
        }

        // no videos found on this attempt
        console.log('No video results found in response on attempt', attempt);
        // if not last attempt, continue to retry
      } catch (error) {
        console.error(`SERP API Error (Trending Videos) attempt ${attempt}:`, error.response?.data || error.message);
        // if last attempt, return failure with helpful message
        if (attempt === attempts) {
          console.error('Full error object:', error);
          return { 
            success: false, 
            message: error.response?.data || error.message || 'Failed to fetch trending videos' 
          };
        }
        // otherwise wait briefly then retry
        await new Promise(r => setTimeout(r, 500 * attempt));
      }
    }

    return { success: false, message: 'No results found after retries' };
  }

  // Search YouTube videos
  async searchVideos(query) {
    try {
      const params = {
        engine: 'youtube',
        search_query: query,
        api_key: SERP_API_KEY,
      };

      console.log('Searching videos with query:', query);
      const response = await axios.get(SERP_API_BASE_URL, { params });
      console.log('Search Response Keys:', Object.keys(response.data));
      
      // Check multiple possible response structures
      let videoResults = null;
      if (response.data.video_results) {
        videoResults = response.data.video_results;
      } else if (response.data.organic_results) {
        videoResults = response.data.organic_results;
      } else if (response.data.videos) {
        videoResults = response.data.videos;
      }
      
      if (videoResults && videoResults.length > 0) {
        console.log('Found videos:', videoResults.length);
        return {
          success: true,
          data: videoResults.map(video => ({
            id: video.link || video.video_id || video.id || '',
            title: video.title || 'Untitled',
            channelName: video.channel?.name || video.channel || video.uploader || 'Unknown',
            imageUrl: video.thumbnail?.static || video.thumbnail || video.image || 'https://via.placeholder.com/320x180?text=No+Image',
            views: video.views || video.view_count || '0',
            publishedDate: video.published_date || video.published_time || video.date || 'Recently',
            duration: video.length || video.duration || 'N/A',
            link: video.link || video.url || '',
            description: video.description || video.snippet || '',
            type: 'video',
          })),
        };
      }

      console.log('No video results found');
      return { success: false, message: 'No results found' };
    } catch (error) {
      console.error('SERP API Error (Search):', error.response?.data || error.message);
      console.error('Full error:', error);
      return { 
        success: false, 
        message: error.response?.data?.error || error.message || 'Failed to search videos' 
      };
    }
  }

  // Get trending images
  async getTrendingImages(query = 'youtube thumbnail ideas') {
    try {
      const params = {
        engine: 'google_images',
        q: query,
        api_key: SERP_API_KEY,
        num: 20,
      };

      console.log('Fetching trending images with query:', query);
      const response = await axios.get(SERP_API_BASE_URL, { params });
      console.log('Images Response Keys:', Object.keys(response.data));
      
      if (response.data && response.data.images_results) {
        console.log('Found images:', response.data.images_results.length);
        return {
          success: true,
          data: response.data.images_results.map(image => ({
            id: image.position || Math.random().toString(),
            title: image.title || 'Untitled',
            imageUrl: image.original || image.thumbnail || '',
            thumbnailUrl: image.thumbnail || image.original || '',
            source: image.source || 'Unknown',
            link: image.link || '',
            sourceUrl: image.source_url || image.link || '',
          })),
        };
      }

      console.log('No images found');
      return { success: false, message: 'No images found' };
    } catch (error) {
      console.error('SERP API Error (Images):', error.response?.data || error.message);
      console.error('Full error:', error);
      return { 
        success: false, 
        message: error.response?.data?.error || error.message || 'Failed to fetch images' 
      };
    }
  }

  // Search images
  async searchImages(query) {
    try {
      const params = {
        engine: 'google_images',
        q: query,
        api_key: SERP_API_KEY,
        num: 20,
      };

      console.log('Searching images with query:', query);
      const response = await axios.get(SERP_API_BASE_URL, { params });
      console.log('Image Search Response Keys:', Object.keys(response.data));
      
      if (response.data && response.data.images_results) {
        console.log('Found images:', response.data.images_results.length);
        return {
          success: true,
          data: response.data.images_results.map(image => ({
            id: image.position || Math.random().toString(),
            title: image.title || 'Untitled',
            imageUrl: image.original || image.thumbnail || '',
            thumbnailUrl: image.thumbnail || image.original || '',
            source: image.source || 'Unknown',
            link: image.link || '',
            sourceUrl: image.source_url || image.link || '',
          })),
        };
      }

      console.log('No images found');
      return { success: false, message: 'No images found' };
    } catch (error) {
      console.error('SERP API Error (Image Search):', error.response?.data || error.message);
      console.error('Full error:', error);
      return { 
        success: false, 
        message: error.response?.data?.error || error.message || 'Failed to search images' 
      };
    }
  }

  // Get AI chat suggestions based on query
  async getChatSuggestions(query) {
    try {
      // Search for related content
      const params = {
        engine: 'google',
        q: `youtube ${query} tips ideas`,
        api_key: SERP_API_KEY,
        num: 10,
      };

      const response = await axios.get(SERP_API_BASE_URL, { params });
      
      if (response.data && response.data.organic_results) {
        return {
          success: true,
          data: response.data.organic_results.map(result => ({
            title: result.title,
            snippet: result.snippet,
            link: result.link,
            source: result.source || result.displayed_link,
          })),
        };
      }

      return { success: false, message: 'No suggestions found' };
    } catch (error) {
      console.error('SERP API Error (Chat):', error.response?.data || error.message);
      return { 
        success: false, 
        message: error.response?.data?.error || 'Failed to get suggestions' 
      };
    }
  }
}

export default new SerpService();
