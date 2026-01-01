// Set custom claims for a Firebase user. Requires a service account key.
const { initializeApp, cert } = require('firebase-admin/app');
const { getAuth } = require('firebase-admin/auth');
const fs = require('fs');
const path = require('path');

const defaultUid = 's6xIY9rj5ubIQzhXPOWVFmwI20w2';
const uid = process.argv[2] || process.env.TARGET_UID || defaultUid;
const claimsInput = process.argv[3] || process.env.TARGET_CLAIMS;
const claims = claimsInput ? JSON.parse(claimsInput) : { admin: true };

const keyPath =
  process.env.GOOGLE_APPLICATION_CREDENTIALS ||
  path.join(__dirname, 'service-account.json');

if (!fs.existsSync(keyPath)) {
  console.error(
    `Service account key not found. Place it at ${keyPath} or set GOOGLE_APPLICATION_CREDENTIALS.`,
  );
  process.exit(1);
}

initializeApp({
  credential: cert(require(keyPath)),
});

getAuth()
  .setCustomUserClaims(uid, claims)
  .then(() => {
    console.log(`Custom claims set for ${uid}: ${JSON.stringify(claims)}`);
    process.exit(0);
  })
  .catch((err) => {
    console.error('Failed to set claims:', err);
    process.exit(1);
  });
