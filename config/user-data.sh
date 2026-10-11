#!/bin/bash
yum update -y
yum install -y nodejs npm

# Fetch dynamic metadata using IMDSv2
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
INSTANCE_AZ=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/placement/availability-zone)
INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)

cat << EOF > /home/ec2-user/server.js
const http = require('http');
const os = require('os');

const INSTANCE_NAME = "$INSTANCE_ID";
const AZ = "$INSTANCE_AZ";

const server = http.createServer((req, res) => {
  if (req.url === '/health') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ status: "healthy", instance: INSTANCE_NAME, az: AZ }));
  } else {
    res.writeHead(200, { 'Content-Type': 'text/plain' });
    res.end(`Instance (\${INSTANCE_NAME}) – \${AZ} (Hostname: \${os.hostname()})\n`);
  }
});

server.listen(80, () => {
  console.log(`Server running on port 80 in AZ: \${AZ} (ID: \${INSTANCE_NAME})`);
});
EOF

# Run server as a background service
nohup node /home/ec2-user/server.js > /var/log/web-app.log 2>&1 &
