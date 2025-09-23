// file: lambdaHospitalLogin.js
import {
  CognitoIdentityProviderClient,
  InitiateAuthCommand,
  GetUserCommand,
} from "@aws-sdk/client-cognito-identity-provider";
import { connectDB } from "./src/config/db.js";
import Hospital from "./src/models/Hospital.js";
import { getSecretHash } from "./src/utils/auth.js";

const REGION = process.env.AWS_REGION;
const HOSPITAL_CLIENT_ID = process.env.HOSPITAL_CLIENT_ID;
const HOSPITAL_CLIENT_SECRET = process.env.HOSPITAL_CLIENT_SECRET;

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

    const { officialEmail, password } = body;
    if (!officialEmail || !password) {
      return {
        statusCode: 400,
        body: JSON.stringify({
          error: true,
          success: false,
          message: "Email and password are required",
        }),
      };
    }

    const secretHash = getSecretHash(
      officialEmail,
      HOSPITAL_CLIENT_ID,
      HOSPITAL_CLIENT_SECRET
    );

    const authCommand = new InitiateAuthCommand({
      AuthFlow: "USER_PASSWORD_AUTH",
      ClientId: HOSPITAL_CLIENT_ID,
      AuthParameters: {
        USERNAME: officialEmail,
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

    // Update hospital status in MongoDB
    const hospital = await Hospital.findOneAndUpdate(
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
      hospital,
    };
  } catch (err) {
    console.error("Hospital login error:", err);
    statusCode = 400;
    resp.error = true;

    if (err.name === "UserNotFoundException") {
      resp.message = "Hospital with provided email not found";
    } else if (err.name === "UserNotConfirmedException") {
      resp.message = "Kindly confirm your account first";
    } else if (err.name === "NotAuthorizedException") {
      resp.message = "Incorrect email or password";
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
