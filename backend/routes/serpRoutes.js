// const express = require('express');
// const router = express.Router();
// const serpController = require('../controllers/serpController');
import express from 'express';
import * as serpController from '../controllers/serpController.js';

const router = express.Router();
// NOTE: Public endpoints — removed auth middleware
router.get('/trending/videos', serpController.getTrendingVideos);
router.get('/search/videos', serpController.searchVideos);
router.get('/trending/images', serpController.getTrendingImages);
router.get('/search/images', serpController.searchImages);
router.get('/chat/suggestions', serpController.getChatSuggestions);


export default router;