import express from 'express';
import cors from 'cors';
import { config } from './config/config.js';
import { connectDB } from './config/database.js';
import { initializeFirebase } from './config/firebase.js';
import { errorHandler } from './middleware/errorHandler.js';

// Import routes
import authRoutes from './routes/authRoutes.js';

// Initialize Express app
const app = express();

// Connect to MongoDB
connectDB();

// Initialize Firebase
initializeFirebase();

// Middleware
app.use(cors({
  origin: config.clientUrl,
  credentials: true
}));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Request logging middleware
app.use((req, res, next) => {
  console.log(`${req.method} ${req.path}`);
  next();
});

// Health check route
app.get('/health', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'Server is running',
    timestamp: new Date().toISOString()
  });
});

// API Routes
app.use('/api/auth', authRoutes);

// Root route
app.get('/', (req, res) => {
  res.json({
    success: true,
    message: 'TubeNix API Server',
    version: '1.0.0',
    endpoints: {
      health: '/health',
      auth: {
        signup: 'POST /api/auth/signup',
        login: 'POST /api/auth/login',
        googleAuth: 'POST /api/auth/google',
        getMe: 'GET /api/auth/me',
        logout: 'POST /api/auth/logout'
      }
    }
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: 'Route not found'
  });
});

// Error handling middleware (must be last)
app.use(errorHandler);

// Start server
const PORT = config.port;

app.listen(PORT, () => {
  console.log('');
  console.log('═══════════════════════════════════════════════════════');
  console.log('🚀 TubeNix Backend Server Started');
  console.log('═══════════════════════════════════════════════════════');
  console.log(`📡 Server running on: http://localhost:${PORT}`);
  console.log(`🌍 Environment: ${config.nodeEnv}`);
  console.log(`🔥 Firebase Project: ${config.firebase.projectId}`);
  console.log('═══════════════════════════════════════════════════════');
  console.log('');
  console.log('Available Endpoints:');
  console.log('  GET  /health           - Health check');
  console.log('  POST /api/auth/signup  - Register new user');
  console.log('  POST /api/auth/login   - Login user');
  console.log('  POST /api/auth/google  - Google Sign In');
  console.log('  GET  /api/auth/me      - Get current user (Protected)');
  console.log('  POST /api/auth/logout  - Logout user (Protected)');
  console.log('');
  console.log('═══════════════════════════════════════════════════════');
});

// Handle unhandled promise rejections
process.on('unhandledRejection', (err) => {
  console.error('❌ Unhandled Promise Rejection:', err);
  // Close server & exit process
  process.exit(1);
});
