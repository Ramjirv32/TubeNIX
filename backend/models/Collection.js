import mongoose from 'mongoose';

const collectionSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  title: {
    type: String,
    required: true,
  },
  description: {
    type: String,
  },
  imageUrl: {
    type: String,
    required: true,
  },
  base64Image: {
    type: String, // For AI-generated thumbnails
  },
  source: {
    type: String,
    enum: ['youtube', 'serp', 'upload', 'ai-generated'],
    default: 'serp',
  },
  type: {
    type: String,
    enum: ['video', 'image', 'thumbnail', 'ai-thumbnail'],
    default: 'image',
  },
  isPublic: {
    type: Boolean,
    default: false, // AI-generated content can be made public
  },
  metadata: {
    channelName: String,
    views: String,
    duration: String,
    publishDate: String,
    link: String,
  },
  isLiked: {
    type: Boolean,
    default: false,
  },
  isSaved: {
    type: Boolean,
    default: true,
  },
  tags: [String],
  createdAt: {
    type: Date,
    default: Date.now,
  },
});

// Index for faster queries
collectionSchema.index({ user: 1, createdAt: -1 });
collectionSchema.index({ user: 1, type: 1 });

const Collection = mongoose.model('Collection', collectionSchema);

export default Collection;
