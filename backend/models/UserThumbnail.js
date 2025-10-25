import mongoose from 'mongoose';

const userThumbnailSchema = new mongoose.Schema({
  userEmail: {
    type: String,
    required: true,
    index: true,
  },
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    index: true,
  },
  prompt: {
    type: String,
    required: true,
    maxlength: 1000,
  },
  originalPrompt: {
    type: String,
    required: true,
    maxlength: 500,
  },
  base64Image: {
    type: String,
    required: true,
  },
  imageSize: {
    type: String, // e.g., "245 KB"
  },
  textResponse: {
    type: String,
    maxlength: 2000,
  },
  isPublic: {
    type: Boolean,
    default: false,
  },
  isDownloaded: {
    type: Boolean,
    default: false,
  },
  downloadCount: {
    type: Number,
    default: 0,
  },
  likes: {
    type: Number,
    default: 0,
  },
  tags: [{
    type: String,
    maxlength: 50,
  }],
  metadata: {
    model: {
      type: String,
      default: 'gemini-2.5-flash-image',
    },
    generatedAt: {
      type: Date,
      default: Date.now,
    },
    variation: {
      type: Number,
      default: 1,
    },
  },
}, {
  timestamps: true,
});

// Indexes for better performance
userThumbnailSchema.index({ userEmail: 1, createdAt: -1 });
userThumbnailSchema.index({ userId: 1, createdAt: -1 });
userThumbnailSchema.index({ isPublic: 1, createdAt: -1 });
userThumbnailSchema.index({ isPublic: 1, likes: -1 });

// Virtual for image URL (if needed for public display)
userThumbnailSchema.virtual('imageUrl').get(function() {
  if (this.isPublic && this.base64Image) {
    return `data:image/png;base64,${this.base64Image}`;
  }
  return null;
});

// Method to get safe data (without base64 for listings)
userThumbnailSchema.methods.toSafeObject = function() {
  const obj = this.toObject();
  delete obj.base64Image; // Remove heavy base64 data for list views
  return obj;
};

// Method to toggle public status
userThumbnailSchema.methods.togglePublic = function() {
  this.isPublic = !this.isPublic;
  return this.save();
};

// Static method to get public thumbnails
userThumbnailSchema.statics.getPublicThumbnails = function(limit = 20, skip = 0) {
  return this.find({ isPublic: true })
    .select('-base64Image') // Exclude heavy base64 data
    .sort({ likes: -1, createdAt: -1 })
    .limit(limit)
    .skip(skip)
    .populate('userId', 'name profilePicture');
};

// Static method to get user's thumbnails
userThumbnailSchema.statics.getUserThumbnails = function(userId, includePrivate = true) {
  const query = includePrivate 
    ? { userId: userId }
    : { userId: userId, isPublic: true };
    
  return this.find(query)
    .select('-base64Image') // Exclude base64 for listing
    .sort({ createdAt: -1 });
};

export default mongoose.model('UserThumbnail', userThumbnailSchema);