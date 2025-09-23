// file: lambdaUserLogin.js
import {
  CognitoIdentityProviderClient,
  InitiateAuthCommand,
  GetUserCommand,
} from "@aws-sdk/client-cognito-identity-provider";
import { connectDB } from "./src/config/db.js";
import User from "./src/models/User.js";
import { getSecretHash } from "./src/utils/auth.js";

const REGION = process.env.AWS_REGION;
const CLIENT_ID = process.env.CLIENT_ID;
const CLIENT_SECRET = process.env.CLIENT_SECRET;

const cognitoClient = new CognitoIdentityProviderClient({ region: REGION });

export const handler = async (event) => {
  const resp = { error: false, success: false, message: "", data: null };
  let statusCode = 200;

  try {
    await connectDB();

    const body =
      event.body && typeof event.body === "string"
        ? JSON.parse(event.body)
        : event.body || event;

    const { email, password } = body;
    if (!email || !password) {
      return {
        statusCode: 400,
        body: JSON.stringify({
          error: true,
          success: false,
          message: "Email and password are required",
        }),
      };
    }

    const secretHash = getSecretHash(email, CLIENT_ID, CLIENT_SECRET);

    const authCommand = new InitiateAuthCommand({
      AuthFlow: "USER_PASSWORD_AUTH",
      ClientId: CLIENT_ID,
      AuthParameters: {
        USERNAME: email,
        PASSWORD: password,
        SECRET_HASH: secretHash,
      },
    });

    const authResponse = await cognitoClient.send(authCommand);

    if (!authResponse.AuthenticationResult) {
      return {
        statusCode: 400,
        body: JSON.stringify({
          error: true,
          success: false,
          message: "Authentication failed or challenge required",
        }),
      };
    }

    const { AccessToken, IdToken, RefreshToken, ExpiresIn, TokenType } =
      authResponse.AuthenticationResult;

    // Fetch Cognito user details
    const userResponse = await cognitoClient.send(
      new GetUserCommand({ AccessToken })
    );

    const sub = userResponse.UserAttributes.find((a) => a.Name === "sub").Value;

    // Update user status in MongoDB
    const user = await User.findOneAndUpdate(
      { sub },
      { online_status: true, last_login: new Date() },
      { new: true }
    );

    resp.success = true;
    resp.message = "Login success";
    resp.data = {
      id_token: IdToken,
      refresh_token: RefreshToken,
      access_token: AccessToken,
      expires_in: ExpiresIn,
      token_type: TokenType,
      user,
    };
  } catch (err) {
    console.error("User login error:", err);
    statusCode = 400;
    resp.error = true;

    if (err.name === "UserNotFoundException") {
      resp.message = "User with provided email not found";
    } else if (err.name === "UserNotConfirmedException") {
      resp.message = "Kindly confirm your account first";
    } else if (err.name === "NotAuthorizedException") {
      resp.message = "Incorrect username or password";
    } else {
      statusCode = 500;
      resp.message = "Something went wrong";
    }
  }

  return {
    statusCode,
    body: JSON.stringify(resp),
  };
};
