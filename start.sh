#!/bin/bash
set -e

# Activate conda environment
source /opt/conda/etc/profile.d/conda.sh
conda activate myenv

# Start SSH service
service ssh start

# Set mail notification config if not exist
if [ ! -f ~/.msmtprc ]; then
cat << EOF > ~/.msmtprc
defaults
auth on
tls on
tls_trust_file /etc/ssl/certs/ca-certificates.crt
logfile ~/.msmtp.log

account yahoo
host smtp.mail.yahoo.com
port 587
from $EMAIL_ADDRESS
user $EMAIL_ADDRESS
password $SMTP_PASSWORD

account default : yahoo
EOF
chmod 600 ~/.msmtprc
fi

export TAILSCALE_SOCKET=/tmp/tailscale.sock
tailscaled --tun=userspace-networking &

# # Wait for Tailscale to start
sleep 3

# Start Tailscale and capture login link
echo "✅ Running tailscale up..."
tailscale up --hostname="my-container-server" --authkey $TAILSCALE_AUTHKEY

# Check if Tailscale is running
if tailscale status | grep -q "my-container-server"; then
    echo "✅ Tailscale is running"
else
    echo "❌ Tailscale failed to start"
    exit 1
fi

# Send email notification
echo -e "Subject: [Myself] Docker Container Server is up.\n\nHello,\n\nYour server has successfully started and is now online.\n\n" | msmtp czsea35@yahoo.com.tw

echo "✅ Running jupyterlab"
# Start JupyterLab (keep the container alive)
jupyter lab --ip=0.0.0.0 --port=8889 --no-browser --allow-root --notebook-dir=/workspace