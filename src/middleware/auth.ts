import type { Request, Response, NextFunction } from "express"
import jwt from "jsonwebtoken"

const JWT_SECRET = process.env.JWT_SECRET || "your-super-secret-jwt-key"

export interface AuthRequest extends Request {
  user?: {
    id: string
    email: string
  }
}

export const authenticateToken = (req: AuthRequest, res: Response, next: NextFunction): void => {
  const authHeader = req.headers["authorization"]
  const token = authHeader && authHeader.split(" ")[1] // Bearer TOKEN

  if (!token) {
    res.status(401).json({
      success: false,
      error: "Access token required",
    })
    return
  }

  try {
    const decoded = jwt.verify(token, JWT_SECRET) as { id: string; email: string }
    req.user = decoded
    next()
  } catch (error) {
    res.status(403).json({
      success: false,
      error: "Invalid or expired token",
    })
  }
}
