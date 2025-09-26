// file: lambdaConfirmSignup.js
import crypto from "crypto";
import {
  CognitoIdentityProviderClient,
  ConfirmSignUpCommand,
} from "@aws-sdk/client-cognito-identity-provider";

const REGION = process.env.AWS_REGION;
const CLIENT_ID = process.env.CLIENT_ID;
const CLIENT_SECRET = process.env.CLIENT_SECRET;

const cognitoClient = new CognitoIdentityProviderClient({ region: REGION });

/**
 * Generate Cognito Secret Hash
 */
function getSecretHash(username, clientId, clientSecret) {
  const msg = username + clientId;
  const hmac = crypto.createHmac("sha256", clientSecret);
  hmac.update(msg);
  return hmac.digest("base64");
}

/**
 * Confirm signup Lambda handler
 */
export const handler = async (event) => {
  console.log("Event:", event);

  const resp = { error: false, success: false, message: "" };
  let statusCode = 200;

  try {
    const body =
      event.body && typeof event.body === "string"
        ? JSON.parse(event.body)
        : event.body || event;

    const username = body.email;
    const code = body.code;

    const secretHash = getSecretHash(username, CLIENT_ID, CLIENT_SECRET);

    const command = new ConfirmSignUpCommand({
      ClientId: CLIENT_ID,
      SecretHash: secretHash,
      Username: username,
      ConfirmationCode: code,
      ForceAliasCreation: false,
    });

    await cognitoClient.send(command);

    resp.success = true;
    resp.message = "Account confirmed successfully";
  } catch (err) {
    console.error("Confirm signup error:", err);
    statusCode = 500;
    resp.error = true;
    resp.success = false;
    resp.message = "Something went wrong";
  }

  return {
    statusCode,
    body: JSON.stringify(resp),
  };
};
