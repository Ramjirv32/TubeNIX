import mongoose from 'mongoose';
import bcrypt from 'bcryptjs';

const userSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: [true, 'Please provide a name'],
      trim: true,
      maxLength: [50, 'Name cannot be more than 50 characters']
    },
    email: {
      type: String,
      required: [true, 'Please provide an email'],
      unique: true,
      lowercase: true,
      trim: true,
      match: [
        /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/,
        'Please provide a valid email'
      ]
    },
    password: {
      type: String,
      required: function() {
        // Password required only if not using Google auth
        return !this.googleId;
      },
      minLength: [6, 'Password must be at least 6 characters'],
      select: false // Don't return password by default
    },
    googleId: {
      type: String,
      unique: true,
      sparse: true // Allows null values to be non-unique
    },
    profilePicture: {
      type: String,
      default: ''
    },
    authProvider: {
      type: String,
      enum: ['local', 'google'],
      default: 'local'
    },
    isEmailVerified: {
      type: Boolean,
      default: false
    },
    role: {
      type: String,
      enum: ['user', 'admin'],
      default: 'user'
    },
    resetPasswordToken: String,
    resetPasswordExpire: Date,
    lastLogin: {
      type: Date,
      default: Date.now
    },
    settings: {
      type: mongoose.Schema.Types.Mixed,
      default: {
        notifications: {
          emailNotifications: true,
          pushNotifications: true,
          trendingVideos: true,
          newFeatures: true
        },
        language: 'English',
        appearance: 'light',
        privacy: {
          profileVisibility: 'public',
          showEmail: false,
          showActivity: true
        },
        security: {
          twoFactorEnabled: false,
          loginAlerts: true
        }
      }
    }
  },
  {
    timestamps: true,
    toJSON: { virtuals: true },
    toObject: { virtuals: true }
  }
);

// Hash password before saving
userSchema.pre('save', async function(next) {
  // Only hash password if it's modified or new
  if (!this.isModified('password')) {
    return next();
  }

  // Don't hash if using Google auth
  if (this.authProvider === 'google') {
    return next();
  }

  try {
    const salt = await bcrypt.genSalt(10);
    this.password = await bcrypt.hash(this.password, salt);
    next();
  } catch (error) {
    next(error);
  }
});

// Method to compare password
userSchema.methods.comparePassword = async function(candidatePassword) {
  try {
    return await bcrypt.compare(candidatePassword, this.password);
  } catch (error) {
    throw new Error('Password comparison failed');
  }
};

// Method to get public profile
userSchema.methods.getPublicProfile = function() {
  return {
    id: this._id,
    name: this.name,
    email: this.email,
    profilePicture: this.profilePicture,
    authProvider: this.authProvider,
    isEmailVerified: this.isEmailVerified,
    role: this.role,
    createdAt: this.createdAt
  };
};

const User = mongoose.model('User', userSchema);

export default User;
