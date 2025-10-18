// File: lambda/login.js
const {
	CognitoIdentityProviderClient,
	InitiateAuthCommand,
} = require('@aws-sdk/client-cognito-identity-provider');

const client = new CognitoIdentityProviderClient({ region: process.env.AWS_REGION });
const CLIENT_ID = process.env.CLIENT_ID;

/**
 * AWS Lambda Handler for Cognito Login
 * Required fields: email, password
 */
exports.lambda_handler = async (event) => {
	try {
		console.log('Incoming event:', event);

		const { email, password } = event;

		if (!email || !password) {
			return {
				statusCode: 400,
				body: JSON.stringify({ error: 'Email and password are required.' }),
			};
		}

		const resp = await signin(email, password);

		return {
			statusCode: 200,
			body: JSON.stringify({
				message: 'Login successful',
				accessToken: resp.AuthenticationResult.AccessToken,
				idToken: resp.AuthenticationResult.IdToken,
				refreshToken: resp.AuthenticationResult.RefreshToken,
			}),
		};
	} catch (error) {
		console.error('Login failed:', error);
		return {
			statusCode: 401,
			body: JSON.stringify({ error: error.message || 'Authentication failed' }),
		};
	}
};

/**
 * Authenticate user with Cognito
 * @param {string} email
 * @param {string} password
 * @returns {Promise<object>}
 */
const signin = async (email, password) => {
	const command = new InitiateAuthCommand({
		AuthFlow: 'USER_PASSWORD_AUTH',
		ClientId: CLIENT_ID,
		AuthParameters: {
			USERNAME: email,
			PASSWORD: password,
		},
	});

	const resp = await client.send(command);
	return resp;
};
