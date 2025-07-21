import type { Request, Response } from "express"
import jwt from "jsonwebtoken"
import User, { type IUser } from "../models/User"

const JWT_SECRET = process.env.JWT_SECRET || "your-super-secret-jwt-key"

// Register User
export const registerUser = async (req: Request, res: Response): Promise<void> => {
  try {
    const { username, email, password } = req.body

    // Validation
    if (!username || !email || !password) {
      res.status(400).json({
        success: false,
        error: "Please provide username, email, and password",
      })
      return
    }

    // Check if user already exists
    const existingUser = await User.findOne({ email })
    if (existingUser) {
      res.status(400).json({
        success: false,
        error: "User with this email already exists",
      })
      return
    }

    // Create new user
    const user: IUser = new User({ username, email, password })
    await user.save()

    // Generate JWT token
    const token = jwt.sign({ id: user._id, email: user.email }, JWT_SECRET, { expiresIn: "7d" })

    res.status(201).json({
      success: true,
      message: "User registered successfully",
      token,
      user: {
        id: user._id,
        username: user.username,
        email: user.email,
      },
    })
  } catch (error: any) {
    console.error("Registration error:", error)
    res.status(500).json({
      success: false,
      error: "Registration failed",
      details: error.message,
    })
  }
}
