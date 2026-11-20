#!/usr/bin/env node
/**
 * Update a quiz document in the Firebase Firestore project `nmms-ponsrischool`
 * from a local quiz JSON file.
 *
 * Usage:
 *   node scripts/update_quiz_firebase.js [options]
 *
 * Options:
 *   --file <path>    Quiz JSON file (default: <repo>/NMMS_SAT_Mock_Test.json)
 *   --doc <id>       Firestore quiz document id (default: cet_test_03)
 *   --dry-run        Print the payload without writing anything
 *   --help           Show this message
 *
 * Authentication (one is required):
 *   1. FIREBASE_ID_TOKEN  - a Firebase ID token from a signed-in admin session
 *   2. FIREBASE_SERVICE_ACCOUNT - path to a service-account JSON file, or the
 *      raw service-account JSON itself (uses OAuth2 with the datastore scope)
 *
 * Examples:
 *   $env:FIREBASE_ID_TOKEN="<token>"; node scripts/update_quiz_firebase.js
 *   $env:FIREBASE_SERVICE_ACCOUNT="C:\path\service-account.json"; node scripts/update_quiz_firebase.js
 *
 * The script writes the standard flat quiz fields used by the web app plus a
 * `dataJson` string field so the Flutter app can also read the quiz from
 * Firestore instead of falling back to its bundled paper52.json.
 */

'use strict';

const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

const PROJECT_ID = 'nmms-ponsrischool';
const DATABASE = '(default)';
const API_KEY = 'AIzaSyC-e516egy6mQlxyV9jPjl2w82kiNoILcU';
const BASE_URL = `https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/${DATABASE}/documents`;
const REPO_ROOT = path.resolve(__dirname, '..');

function parseArgs(argv) {
  const opts = {
    file: path.join(REPO_ROOT, 'NMMS_SAT_Mock_Test.json'),
    doc: 'cet_test_03',
    dryRun: false,
    help: false,
  };
  for (let i = 0; i < argv.length; i++) {
    const arg = argv[i];
    if (arg === '--dry-run') opts.dryRun = true;
    else if (arg === '--help' || arg === '-h') opts.help = true;
    else if (arg === '--file' || arg === '--doc') {
      const value = argv[++i];
      if (!value) throw new Error(`Missing value for ${arg}`);
      opts[arg === '--file' ? 'file' : 'doc'] = value;
    } else {
      throw new Error(`Unknown option: ${arg}`);
    }
  }
  return opts;
}

function encodeValue(value) {
  if (value === null || value === undefined) return { nullValue: null };
  if (typeof value === 'string') return { stringValue: value };
  if (typeof value === 'boolean') return { booleanValue: value };
  if (typeof value === 'number') {
    return Number.isInteger(value)
      ? { integerValue: String(value) }
      : { doubleValue: value };
  }
  if (Array.isArray(value)) {
    return { arrayValue: { values: value.map(encodeValue) } };
  }
  if (typeof value === 'object') {
    const fields = {};
    for (const [key, val] of Object.entries(value)) fields[key] = encodeValue(val);
    return { mapValue: { fields } };
  }
  throw new Error(`Unsupported value type: ${typeof value}`);
}

function b64url(input) {
  return Buffer.from(input).toString('base64url');
}

async function getAccessToken(serviceAccountRaw) {
  let sa;
  try {
    sa = JSON.parse(serviceAccountRaw);
  } catch (err) {
    sa = JSON.parse(fs.readFileSync(serviceAccountRaw, 'utf8'));
  }
  if (!sa.client_email || !sa.private_key) {
    throw new Error('Service account JSON must contain client_email and private_key');
  }

  const now = Math.floor(Date.now() / 1000);
  const header = { alg: 'RS256', typ: 'JWT' };
  const payload = {
    iss: sa.client_email,
    scope: 'https://www.googleapis.com/auth/datastore',
    aud: 'https://oauth2.googleapis.com/token',
    iat: now,
    exp: now + 3600,
  };
  const unsigned = `${b64url(JSON.stringify(header))}.${b64url(JSON.stringify(payload))}`;
  const signature = crypto.createSign('RSA-SHA256').update(unsigned).sign(sa.private_key);
  const assertion = `${unsigned}.${signature.toString('base64url')}`;

  const response = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
      assertion,
    }),
  });
  const body = await response.json();
  if (!response.ok) {
    throw new Error(`OAuth2 token exchange failed: ${JSON.stringify(body)}`);
  }
  return body.access_token;
}

async function resolveAuth() {
  if (process.env.FIREBASE_ID_TOKEN) {
    return { type: 'Bearer', token: process.env.FIREBASE_ID_TOKEN };
  }
  if (process.env.FIREBASE_SERVICE_ACCOUNT) {
    const token = await getAccessToken(process.env.FIREBASE_SERVICE_ACCOUNT);
    return { type: 'Bearer', token };
  }
  throw new Error(
    'No Firebase credentials found. Set FIREBASE_ID_TOKEN or FIREBASE_SERVICE_ACCOUNT.\n' +
    'Firestore does not allow unauthenticated writes on this project.'
  );
}

async function main() {
  const opts = parseArgs(process.argv.slice(2));
  if (opts.help) {
    console.log(fs.readFileSync(__filename, 'utf8').split('*/')[0] + '*/');
    return;
  }

  const filePath = path.resolve(opts.file);
  const quiz = JSON.parse(fs.readFileSync(filePath, 'utf8'));
  if (!Array.isArray(quiz.questions) || quiz.questions.length === 0) {
    throw new Error('Quiz JSON must contain a non-empty "questions" array');
  }

  const timestamp = new Date().toISOString();
  const fields = {
    title: encodeValue(quiz.title),
    durationMinutes: encodeValue(quiz.durationMinutes),
    school: encodeValue(quiz.school),
    questions: encodeValue(quiz.questions),
    totalQuestions: encodeValue(quiz.questions.length),
    totalMarks: encodeValue(quiz.questions.length),
    updatedAt: encodeValue(timestamp),
    // Flutter app reads this single string field (see fetchQuizData in main.dart).
    dataJson: encodeValue(
      JSON.stringify({ ...quiz, id: quiz.id || opts.doc, updatedAt: timestamp })
    ),
  };

  if (opts.dryRun) {
    console.log(JSON.stringify({ doc: opts.doc, fields }, null, 2));
    return;
  }

  const auth = await resolveAuth();
  const url = `${BASE_URL}/quizzes/${encodeURIComponent(opts.doc)}?key=${API_KEY}`;
  const mask = Object.keys(fields)
    .map((name) => `updateMask.fieldPaths=${encodeURIComponent(name)}`)
    .join('&');

  const response = await fetch(`${url}&${mask}`, {
    method: 'PATCH',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `${auth.type} ${auth.token}`,
    },
    body: JSON.stringify({ fields }),
  });
  const body = await response.text();
  if (!response.ok) {
    throw new Error(`Firestore update failed (${response.status}): ${body}`);
  }

  const saved = JSON.parse(body);
  console.log(`✓ Updated quizzes/${opts.doc}`);
  console.log(`  title:     ${quiz.title}`);
  console.log(`  questions: ${quiz.questions.length}`);
  console.log(`  updatedAt: ${timestamp}`);
  console.log(`  writeTime: ${saved.updateTime || 'n/a'}`);

  const verify = await fetch(`${url}`, {
    headers: { Authorization: `${auth.type} ${auth.token}` },
  });
  if (verify.ok) {
    const doc = await verify.json();
    const count = doc.fields && doc.fields.questions && doc.fields.questions.arrayValue
      ? doc.fields.questions.arrayValue.values.length
      : 0;
    console.log(`✓ Verified: ${doc.name} (${count} questions)`);
  } else {
    console.warn(`! Verification read failed: ${verify.status}`);
  }
}

main().catch((err) => {
  console.error(`Error: ${err.message}`);
  process.exitCode = 1;
});
