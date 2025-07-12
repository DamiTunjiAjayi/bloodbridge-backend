// configure server.js (Entry Point)
// --------------------------------------
// This file initializes the Express app, connects to MongoDB, and sets up global middleware.
// Here's what each section does:

// Load environment variables from .env
// -------------------------------------
// Ensures process.env.MONGODB_URI and process.env.PORT are available.
const dotenv = require('dotenv');
dotenv.config();

// Import dependencies
// -------------------
// express    - for building HTTP API routes
// mongoose   - for connecting to MongoDB and defining models
// cors       - to allow cross-origin requests (e.g., from your frontend)
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');

// Import route modules
// --------------------
// authRoutes handles all /api/auth/* endpoints
const authRoutes = require('./routes/authRoutes');

// Create an Express application
// ------------------------------
const app = express();

// Middleware
// ----------
// cors(): enables CORS for all origins (adjust in production)
// express.json(): parses incoming JSON request bodies into req.body
app.use(cors());
app.use(express.json());

// Register routes
// ---------------
// All auth-related requests go through the authRoutes router
app.use('/api/auth', authRoutes);

// Connect to MongoDB Atlas
// ------------------------
// Uses the MONGO_URI environment variable
mongoose
  .connect(process.env.MONGODB_URI, {
    useNewUrlParser: true,
    useUnifiedTopology: true
  })
  .then(() => {
    console.log('MongoDB connected');
    // Start the server only after a successful DB connection
    app.listen(process.env.PORT, () =>
      console.log(`Server running on port ${process.env.PORT}`)
    );
  })
  .catch((err) => console.error('MongoDB connection error:', err));