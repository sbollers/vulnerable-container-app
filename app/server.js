// DEMO ONLY - intentionally vulnerable Node app.
// Contains classic code-scanning findings: command injection, code injection,
// hardcoded credentials, and use of vulnerable dependencies.
const express = require('express');
const { exec } = require('child_process');
const app = express();

// --- Hardcoded credentials (credential / secret scanning findings) ---
// NOTE: these are fake, non-functional example values for the demo only.
const AWS_ACCESS_KEY_ID = "AKIAIOSFODNN7EXAMPLE";
const AWS_SECRET_ACCESS_KEY = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY";
const DB_PASSWORD = "P@ssw0rd-demo-do-not-use!";
const JWT_SIGNING_KEY = "super-secret-demo-signing-key";

app.get('/health', (req, res) => res.send('ok'));

// --- CWE-78: OS Command Injection ---
// User-controlled input concatenated into a shell command.
app.get('/ping', (req, res) => {
  const host = req.query.host;
  exec('ping -c 1 ' + host, (err, stdout, stderr) => {
    if (err) return res.status(500).send(String(stderr));
    res.send(stdout);
  });
});

// --- CWE-95: Code Injection via eval ---
app.get('/calc', (req, res) => {
  // Directly evaluates attacker-controlled input
  const result = eval(req.query.expr);
  res.send(String(result));
});

// --- CWE-89-ish: string-built query (no real DB, illustrative) ---
app.get('/user', (req, res) => {
  const query = "SELECT * FROM users WHERE name = '" + req.query.name + "'";
  res.send(query);
});

app.listen(3000, () => console.log('vulnerable-container-app listening on 3000'));
