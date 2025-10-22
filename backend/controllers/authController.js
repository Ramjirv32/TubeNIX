import User from '../models/User.js';
import { generateToken } from '../utils/jwt.js';
import { verifyFirebaseToken } from '../config/firebase.js';

/**
 * @desc    Register new user
 * @route   POST /api/auth/signup
 * @access  Public
 */
export const signup = async (req, res, next) => {
  try {
    const { name, email, password } = req.body;

    // Validate input
    if (!name || !email || !password) {
      return res.status(400).json({
        success: false,
        message: 'Please provide name, email and password'
      });
    }

    // Check if user already exists
    const existingUser = await User.findOne({ email });
    
    if (existingUser) {
      return res.status(400).json({
        success: false,
        message: 'Email already registered. Please login instead.'
      });
    }

    // Validate password length
    if (password.length < 6) {
      return res.status(400).json({
        success: false,
        message: 'Password must be at least 6 characters'
      });
    }

    // Create user
    const user = await User.create({
      name,
      email,
      password,
      authProvider: 'local'
    });

    // Generate JWT token
    const token = generateToken(user._id);

    // Update last login
    user.lastLogin = Date.now();
    await user.save();

    res.status(201).json({
      success: true,
      message: 'User registered successfully',
      data: {
        user: user.getPublicProfile(),
        token
      }
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @desc    Login user
 * @route   POST /api/auth/login
 * @access  Public
 */
export const login = async (req, res, next) => {
  try {
    const { email, password } = req.body;

    // Validate input
    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: 'Please provide email and password'
      });
    }

    // Check if user exists (include password field)
    const user = await User.findOne({ email }).select('+password');

    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'Email is not registered. Please sign up first.'
      });
    }

    // Check if user used Google auth
    if (user.authProvider === 'google') {
      return res.status(400).json({
        success: false,
        message: 'This account uses Google Sign-In. Please use Google to login.'
      });
    }

    // Verify password
    const isPasswordValid = await user.comparePassword(password);

    if (!isPasswordValid) {
      return res.status(401).json({
        success: false,
        message: 'Invalid email or password'
      });
    }

    // Generate JWT token
    const token = generateToken(user._id);

    // Update last login
    user.lastLogin = Date.now();
    await user.save();

    res.status(200).json({
      success: true,
      message: 'Login successful',
      data: {
        user: user.getPublicProfile(),
        token
      }
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @desc    Google Sign In
 * @route   POST /api/auth/google
 * @access  Public
 */
export const googleAuth = async (req, res, next) => {
  try {
    const { idToken, name, email, photoURL, uid } = req.body;

    // Validate input
    if (!email || !uid) {
      return res.status(400).json({
        success: false,
        message: 'Please provide valid Google authentication data'
      });
    }

    // Optional: Verify Firebase token (requires Firebase Admin SDK setup)
    // const decodedToken = await verifyFirebaseToken(idToken);

    // Check if user exists
    let user = await User.findOne({ email });

    if (user) {
      // User exists - check if they used email/password before
      if (user.authProvider === 'local') {
        return res.status(400).json({
          success: false,
          message: 'This email is already registered with email/password. Please login with email and password.'
        });
      }

      // Update Google ID if needed
      if (!user.googleId) {
        user.googleId = uid;
      }
    } else {
      // Create new user with Google auth
      user = await User.create({
        name: name || email.split('@')[0],
        email,
        googleId: uid,
        profilePicture: photoURL || '',
        authProvider: 'google',
        isEmailVerified: true // Google emails are pre-verified
      });
    }

    // Generate JWT token
    const token = generateToken(user._id);

    // Update last login
    user.lastLogin = Date.now();
    await user.save();

    res.status(200).json({
      success: true,
      message: user.createdAt.getTime() === user.updatedAt.getTime() 
        ? 'Account created successfully with Google' 
        : 'Login successful',
      data: {
        user: user.getPublicProfile(),
        token
      }
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @desc    Get current logged in user
 * @route   GET /api/auth/me
 * @access  Private
 */
export const getMe = async (req, res, next) => {
  try {
    const user = await User.findById(req.user.id);

    res.status(200).json({
      success: true,
      data: {
        user: user.getPublicProfile()
      }
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @desc    Logout user / clear cookie
 * @route   POST /api/auth/logout
 * @access  Private
 */
export const logout = async (req, res, next) => {
  try {
    res.status(200).json({
      success: true,
      message: 'Logout successful',
      data: {}
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @desc    Change password
 * @route   PUT /api/auth/change-password
 * @access  Private
 */
export const changePassword = async (req, res, next) => {
  try {
    const { currentPassword, newPassword } = req.body;

    // Validate input
    if (!currentPassword || !newPassword) {
      return res.status(400).json({
        success: false,
        message: 'Please provide current password and new password'
      });
    }

    // Validate new password length
    if (newPassword.length < 6) {
      return res.status(400).json({
        success: false,
        message: 'New password must be at least 6 characters'
      });
    }

    // Get user with password field
    const user = await User.findById(req.user.id).select('+password');

    // Check if user used Google auth
    if (user.authProvider === 'google') {
      return res.status(400).json({
        success: false,
        message: 'Cannot change password for Google accounts'
      });
    }

    // Verify current password
    const isMatch = await user.comparePassword(currentPassword);

    if (!isMatch) {
      return res.status(401).json({
        success: false,
        message: 'Current password is incorrect'
      });
    }

    // Update password
    user.password = newPassword;
    await user.save();

    res.status(200).json({
      success: true,
      message: 'Password changed successfully'
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @desc    Update user profile
 * @route   PUT /api/auth/profile
 * @access  Private
 */
export const updateProfile = async (req, res, next) => {
  try {
    const { name, profilePicture } = req.body;

    const updateData = {};
    if (name) updateData.name = name;
    if (profilePicture) updateData.profilePicture = profilePicture;

    const user = await User.findByIdAndUpdate(
      req.user.id,
      updateData,
      { new: true, runValidators: true }
    );

    res.status(200).json({
      success: true,
      message: 'Profile updated successfully',
      data: {
        user: user.getPublicProfile()
      }
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @desc    Update user email
 * @route   PUT /api/auth/email
 * @access  Private
 */
export const updateEmail = async (req, res, next) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: 'Please provide email and password'
      });
    }

    const user = await User.findById(req.user.id);

    // Verify password for security
    const isPasswordValid = await user.comparePassword(password);
    if (!isPasswordValid) {
      return res.status(401).json({
        success: false,
        message: 'Password is incorrect'
      });
    }

    // Check if email already exists
    const existingUser = await User.findOne({ email });
    if (existingUser && existingUser._id.toString() !== req.user.id) {
      return res.status(400).json({
        success: false,
        message: 'Email already in use'
      });
    }

    user.email = email;
    user.isEmailVerified = false; // Reset verification status
    await user.save();

    res.status(200).json({
      success: true,
      message: 'Email updated successfully',
      data: {
        user: user.getPublicProfile()
      }
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @desc    Update user settings
 * @route   PUT /api/auth/settings
 * @access  Private
 */
export const updateSettings = async (req, res, next) => {
  try {
    const { settingsType, settings } = req.body;

    const user = await User.findById(req.user.id);
    
    if (!user.settings) {
      user.settings = {};
    }

    // Update specific settings type
    user.settings[settingsType] = settings;
    user.markModified('settings');
    await user.save();

    res.status(200).json({
      success: true,
      message: `${settingsType} settings updated successfully`,
      data: {
        settings: user.settings
      }
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @desc    Get user settings
 * @route   GET /api/auth/settings
 * @access  Private
 */
export const getSettings = async (req, res, next) => {
  try {
    const user = await User.findById(req.user.id);

    res.status(200).json({
      success: true,
      data: {
        settings: user.settings || {}
      }
    });
  } catch (error) {
    next(error);
  }
};
