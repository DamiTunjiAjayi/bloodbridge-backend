// file: lambdaUserSignup.js
import crypto from "crypto";
import {
  CognitoIdentityProviderClient,
  SignUpCommand,
} from "@aws-sdk/client-cognito-identity-provider";
import { connectDB } from "./src/config/db.js";
import User from "./src/models/User.js";

const REGION = process.env.AWS_REGION;
const CLIENT_ID = process.env.CLIENT_ID;
const CLIENT_SECRET = process.env.CLIENT_SECRET;

const cognitoClient = new CognitoIdentityProviderClient({ region: REGION });

function getSecretHash(username, clientId, clientSecret) {
  const msg = username + clientId;
  const hmac = crypto.createHmac("sha256", clientSecret);
  hmac.update(msg);
  return hmac.digest("base64");
}

export const handler = async (event) => {
  const resp = { error: false, success: false, message: "", data: null };
  let statusCode = 200;

  try {
    await connectDB();

    const body =
      event.body && typeof event.body === "string"
        ? JSON.parse(event.body)
        : event.body || event;

    const {
      name,
      dateOfBirth,
      phoneNumber,
      email,
      gender,
      password,
      bloodGroup,
      genotype,
      medicalCondition,
      lastDonationDate,
      currentLocation,
      preferredRadius,
      preferredCenters,
    } = body;

    const attributes = [
      { Name: "email", Value: email },
      { Name: "name", Value: name },
      { Name: "birthdate", Value: dateOfBirth },
      { Name: "phone_number", Value: phoneNumber },
      { Name: "gender", Value: gender },
      { Name: "custom:bloodGroup", Value: bloodGroup },
      { Name: "custom:genotype", Value: genotype },
      { Name: "custom:medicalCondition", Value: medicalCondition },
      { Name: "custom:currentLocation", Value: currentLocation },
    ];
    if (lastDonationDate) attributes.push({ Name: "custom:lastDonationDate", Value: lastDonationDate });
    if (preferredRadius) attributes.push({ Name: "custom:preferredRadius", Value: preferredRadius });
    if (preferredCenters && preferredCenters.length > 0) {
      attributes.push({ Name: "custom:preferredCenters", Value: preferredCenters.join(",") });
    }

    const secretHash = getSecretHash(email, CLIENT_ID, CLIENT_SECRET);

    const signUpResponse = await cognitoClient.send(
      new SignUpCommand({
        ClientId: CLIENT_ID,
        SecretHash: secretHash,
        Username: email,
        Password: password,
        UserAttributes: attributes,
      })
    );

    const userSub = signUpResponse.UserSub;

    await User.create({
      sub: userSub,
      email,
      name,
      dateOfBirth,
      phoneNumber,
      gender,
      bloodGroup,
      genotype,
      medicalCondition,
      lastDonationDate,
      currentLocation,
      preferredRadius,
      preferredCenters,
    });

    resp.success = true;
    resp.message = "Successfully signed up";
    resp.data = { userSub };
  } catch (err) {
    console.error("User signup error:", err);
    statusCode = 400;
    resp.error = true;

    if (err.name === "UsernameExistsException") {
      resp.message = "User with this email already exists.";
    } else if (err.name === "InvalidPasswordException") {
      resp.message =
        "Kindly use a stronger password. It must include a symbol, number and an uppercase character.";
    } else {
      statusCode = 500;
      resp.message = "Something went wrong.";
    }
  }

  return {
    statusCode,
    body: JSON.stringify(resp),
  };
};
