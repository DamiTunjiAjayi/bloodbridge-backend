import { Router } from "express"
import { registerUser } from "../controllers/authController"

const router = Router()

// Authentication routes
router.post("/signup", registerUser)


export default router
