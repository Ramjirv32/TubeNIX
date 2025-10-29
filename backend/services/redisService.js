import { createClient } from 'redis';

class RedisService {
  constructor() {
    this.client = null;
    this.isConnected = false;
    this.init();
  }

  async init() {
    try {
      this.client = createClient({
        url: 'redis://localhost:6379'
      });

      this.client.on('error', (err) => {
        console.error('Redis Client Error:', err);
        this.isConnected = false;
      });

      this.client.on('connect', () => {
        console.log('✅ Redis connected successfully');
        this.isConnected = true;
      });

      this.client.on('disconnect', () => {
        console.log('⚠️ Redis disconnected');
        this.isConnected = false;
      });

      await this.client.connect();
    } catch (error) {
      console.error('Failed to initialize Redis:', error);
      this.isConnected = false;
    }
  }

  // Cache SERP API results
  async cacheSearchResults(query, results, ttl = 3600) {
    if (!this.isConnected) return false;
    
    try {
      const key = `serp:${query.toLowerCase().replace(/\s+/g, '_')}`;
      await this.client.setEx(key, ttl, JSON.stringify(results));
      console.log(`Cached search results for: ${query}`);
      return true;
    } catch (error) {
      console.error('Error caching search results:', error);
      return false;
    }
  }

  // Get cached search results
  async getCachedSearchResults(query) {
    if (!this.isConnected) return null;
    
    try {
      const key = `serp:${query.toLowerCase().replace(/\s+/g, '_')}`;
      const cached = await this.client.get(key);
      if (cached) {
        console.log(`Retrieved cached results for: ${query}`);
        return JSON.parse(cached);
      }
      return null;
    } catch (error) {
      console.error('Error getting cached results:', error);
      return null;
    }
  }

  // Cache user collections
  async cacheUserCollections(userId, collections, ttl = 1800) {
    if (!this.isConnected) return false;
    
    try {
      const key = `collections:${userId}`;
      await this.client.setEx(key, ttl, JSON.stringify(collections));
      console.log(`Cached collections for user: ${userId}`);
      return true;
    } catch (error) {
      console.error('Error caching collections:', error);
      return false;
    }
  }

  // Get cached user collections
  async getCachedUserCollections(userId) {
    if (!this.isConnected) return null;
    
    try {
      const key = `collections:${userId}`;
      const cached = await this.client.get(key);
      if (cached) {
        console.log(`Retrieved cached collections for user: ${userId}`);
        return JSON.parse(cached);
      }
      return null;
    } catch (error) {
      console.error('Error getting cached collections:', error);
      return null;
    }
  }

  // Cache trending content
  async cacheTrendingContent(type, content, ttl = 1800) {
    if (!this.isConnected) return false;
    
    try {
      const key = `trending:${type}`;
      await this.client.setEx(key, ttl, JSON.stringify(content));
      console.log(`Cached trending ${type} content`);
      return true;
    } catch (error) {
      console.error('Error caching trending content:', error);
      return false;
    }
  }

  // Get cached trending content
  async getCachedTrendingContent(type) {
    if (!this.isConnected) return null;
    
    try {
      const key = `trending:${type}`;
      const cached = await this.client.get(key);
      if (cached) {
        console.log(`Retrieved cached trending ${type} content`);
        return JSON.parse(cached);
      }
      return null;
    } catch (error) {
      console.error('Error getting cached trending content:', error);
      return null;
    }
  }

  // Invalidate user collections cache
  async invalidateUserCollections(userId) {
    if (!this.isConnected) return false;
    
    try {
      const key = `collections:${userId}`;
      await this.client.del(key);
      console.log(`Invalidated collections cache for user: ${userId}`);
      return true;
    } catch (error) {
      console.error('Error invalidating collections cache:', error);
      return false;
    }
  }

  // Clear all search cache (admin function)
  async clearSearchCache() {
    if (!this.isConnected) return false;
    
    try {
      const keys = await this.client.keys('serp:*');
      if (keys.length > 0) {
        await this.client.del(keys);
        console.log(`Cleared ${keys.length} search cache entries`);
      }
      return true;
    } catch (error) {
      console.error('Error clearing search cache:', error);
      return false;
    }
  }

  // Health check
  async isHealthy() {
    if (!this.isConnected) return false;
    
    try {
      const result = await this.client.ping();
      return result === 'PONG';
    } catch (error) {
      return false;
    }
  }

  // Close connection
  async close() {
    try {
      if (this.client) {
        await this.client.quit();
        console.log('Redis connection closed');
      }
    } catch (error) {
      console.error('Error closing Redis connection:', error);
    }
  }
}

export default new RedisService();