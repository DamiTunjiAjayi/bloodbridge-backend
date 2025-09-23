// file: lambdaHospitalSignup.js
import crypto from "crypto";
import {
  CognitoIdentityProviderClient,
  SignUpCommand,
} from "@aws-sdk/client-cognito-identity-provider";
import { connectDB } from "./src/config/db.js";
import Hospital from "./src/models/Hospital.js";

const REGION = process.env.AWS_REGION;
const HOSPITAL_CLIENT_ID = process.env.HOSPITAL_CLIENT_ID;
const HOSPITAL_CLIENT_SECRET = process.env.HOSPITAL_CLIENT_SECRET;

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
      hospitalType,
      registrationNumber,
      phoneNumber,
      officialEmail,
      password,
      fullAddress,
      state,
      lga,
      contactPersonName,
      contactPersonRole,
      contactPersonPhone,
    } = body;

    const attributes = [
      { Name: "email", Value: officialEmail },
      { Name: "phone_number", Value: phoneNumber },
      { Name: "custom:hospitalType", Value: hospitalType },
      { Name: "custom:registrationNumber", Value: registrationNumber },
      { Name: "custom:fullAddress", Value: fullAddress },
      { Name: "custom:state", Value: state },
      { Name: "custom:lga", Value: lga },
      { Name: "custom:contactPersonName", Value: contactPersonName },
      { Name: "custom:contactPersonRole", Value: contactPersonRole },
      { Name: "custom:contactPersonPhone", Value: contactPersonPhone },
    ];

    const secretHash = getSecretHash(
      officialEmail,
      HOSPITAL_CLIENT_ID,
      HOSPITAL_CLIENT_SECRET
    );

    const signUpResponse = await cognitoClient.send(
      new SignUpCommand({
        ClientId: HOSPITAL_CLIENT_ID,
        SecretHash: secretHash,
        Username: officialEmail,
        Password: password,
        UserAttributes: attributes,
      })
    );

    const hospitalSub = signUpResponse.UserSub;

    await Hospital.create({
      sub: hospitalSub,
      officialEmail,
      hospitalType,
      registrationNumber,
      phoneNumber,
      fullAddress,
      state,
      lga,
      contactPersonName,
      contactPersonRole,
      contactPersonPhone,
    });

    resp.success = true;
    resp.message = "Hospital successfully signed up";
    resp.data = { hospitalSub };
  } catch (err) {
    console.error("Hospital signup error:", err);
    statusCode = 400;
    resp.error = true;

    if (err.name === "UsernameExistsException") {
      resp.message = "Hospital with this email already exists.";
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
