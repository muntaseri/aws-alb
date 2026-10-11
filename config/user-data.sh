#!/bin/bash
yum update -y
yum install -y nodejs npm

cat << 'EOF' > /home/ec2-user/server.js
const http = require('http');
const os = require('os');

const INSTANCE_NAME = process.env.INSTANCE_NAME || "Instance 1";
const AZ = process.env.AZ || "us-east-1a";

const server = http.createServer((req, res) => {
  if (req.url === '/health') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ status: "healthy", instance: INSTANCE_NAME, az: AZ }));
  } else {
    res.writeHead(200, { 'Content-Type': 'text/plain' });
    res.end(`${INSTANCE_NAME} – ${AZ} (Host: ${os.hostname()})\n`);
  }
});

server.listen(80, () => {
  console.log(`${INSTANCE_NAME} running on port 80 in ${AZ}`);
});
EOF

# Run server as a background service
nohup node /home/ec2-user/server.js > /var/log/web-app.log 2>&1 &
