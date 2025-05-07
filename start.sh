#!/bin/bash
set -e

# Activate conda environment
source /opt/conda/etc/profile.d/conda.sh
conda activate myenv

# Start SSH service
if [ "$ENABLE_SSH" = "true" ]; then
    echo "Starting SSH service..."
    service ssh start
fi

MAIL_FLAG=FALSE
if [ -n "$EMAIL_ADDRESS" ] && [ -n "$SMTP_PASSWORD" ]; then
    MAIL_FLAG=TRUE
fi

# Set mail notification config if not exist
if [ "$MAIL_FLAG" = "TRUE" ] && [ ! -f ~/.msmtprc ]; then
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

# Tailcale
VPN_FLAG=FALSE
if [ -n "$TAILSCALE_AUTHKEY" ]; then
    VPN_FLAG=TRUE
fi

if [ "$VPN_FLAG" = "TRUE" ]; then
    export TAILSCALE_SOCKET=/tmp/tailscale.sock
    tailscaled --tun=userspace-networking &

    # # Wait for Tailscale to start
    sleep 3

    HOSTNAME_VALUE="${HOSTNAME:-my-container-server}"
    # Start Tailscale and capture login link
    echo "✅ Running tailscale up..."
    tailscale up --hostname="$HOSTNAME_VALUE" --authkey $TAILSCALE_AUTHKEY

    # Check if Tailscale is running
    if tailscale status | grep -q "$HOSTNAME_VALUE"; then
        echo "✅ Tailscale is running"
    else
        echo "❌ Tailscale failed to start"
        exit 1
    fi
fi


# Send email notification
if [ "$MAIL_FLAG" = "TRUE" ] ; then
    echo -e "Subject: [Myself] Docker Container Server is up.\n\nHello,\n\nYour server has successfully started and is now online.\n\n" | msmtp czsea35@yahoo.com.tw  
fi

echo "✅ Running jupyterlab"
# Start JupyterLab (keep the container alive)
jupyter lab \
    --ip=0.0.0.0 \
    --port=8889 \
    --no-browser \
    --allow-root \
    --notebook-dir=/workspace