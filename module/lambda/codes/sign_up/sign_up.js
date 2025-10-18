// File: lambda/signup.js
const {
  CognitoIdentityProviderClient,
  SignUpCommand,
} = require('@aws-sdk/client-cognito-identity-provider');

const client = new CognitoIdentityProviderClient({ region: process.env.AWS_REGION });
const CLIENT_ID = process.env.CLIENT_ID;

exports.lambda_handler = async (event) => {
  console.log('Incoming event:', event);

  try {
    const {
      name,
      dateOfBirth,
      phoneNumber,
      email,
      gender,
      password,
      confirmPassword,
      bloodGroup,
      genotype,
      medicalCondition,
      lastDonationDate,
      currentLocation,
      preferredDonationRadius,
      preferredDonationCenters,
      agreeToDonate,
      allowContact
    } = event;

    // Basic validation
    const requiredFields = [
      'name',
      'dateOfBirth',
      'phoneNumber',
      'email',
      'gender',
      'password',
      'confirmPassword',
      'bloodGroup',
      'genotype',
      'medicalCondition',
      'lastDonationDate',
      'currentLocation',
      'preferredDonationRadius',
      'preferredDonationCenters',
      'agreeToDonate'
    ];

    for (const field of requiredFields) {
      if (!event[field]) {
        return {
          statusCode: 400,
          body: JSON.stringify({ error: `${field} is required.` })
        };
      }
    }

    if (password !== confirmPassword) {
      return {
        statusCode: 400,
        body: JSON.stringify({ error: 'Passwords do not match.' })
      };
    }

    const signupResponse = await signup({
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
      preferredDonationRadius,
      preferredDonationCenters,
      agreeToDonate,
      allowContact
    });

    return {
      statusCode: 200,
      body: JSON.stringify({
        message: 'Signup successful',
        response: signupResponse
      })
    };
  } catch (err) {
    console.error('Signup error:', err);
    return {
      statusCode: 500,
      body: JSON.stringify({ error: err.message })
    };
  }
};

const signup = async (userData) => {
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
    preferredDonationRadius,
    preferredDonationCenters,
    agreeToDonate,
    allowContact
  } = userData;

  const input = {
    ClientId: CLIENT_ID,
    Username: email,
    Password: password,
    UserAttributes: [
      { Name: 'email', Value: email },
      { Name: 'phone_number', Value: phoneNumber },
      { Name: 'name', Value: name },
      { Name: 'gender', Value: gender },
      { Name: 'birthdate', Value: dateOfBirth },

      // Custom attributes — must exist in your Cognito User Pool
      { Name: 'custom:blood_group', Value: bloodGroup },
      { Name: 'custom:genotype', Value: genotype },
      { Name: 'custom:medical_condition', Value: medicalCondition },
      { Name: 'custom:last_donation_date', Value: lastDonationDate },
      { Name: 'custom:current_location', Value: currentLocation },
      { Name: 'custom:preferred_donation_radius', Value: preferredDonationRadius },
      { Name: 'custom:preferred_donation_centers', Value: Array.isArray(preferredDonationCenters) ? preferredDonationCenters.join(', ') : preferredDonationCenters },
      { Name: 'custom:agree_to_donate', Value: String(agreeToDonate) },
      { Name: 'custom:allow_contact', Value: String(allowContact) },
    ],
  };

  const command = new SignUpCommand(input);
  const resp = await client.send(command);
  return resp;
};
