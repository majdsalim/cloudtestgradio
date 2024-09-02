#!/bin/bash

# Define the directory paths for ComfyUI and Gradio app
COMFYUI_DIR="/home/majdsalim/ComfyUI"
GRADIO_DIR="/home/majdsalim/cloudtestgradio"

# Get the public IP of the VM
PUBLIC_IP=$(curl -s httpbin.org/ip | jq -r .origin)

# Create and write the run_the_server.sh script for ComfyUI
echo "#!/bin/bash
python3 ${COMFYUI_DIR}/main.py --listen" > ${COMFYUI_DIR}/run_the_server.sh

# Make it executable
chmod +x ${COMFYUI_DIR}/run_the_server.sh

# Create and write the run_the_server.sh script for Gradio
echo "#!/bin/bash
python3 ${GRADIO_DIR}/intermediate.py --server_port 7860 --share" > ${GRADIO_DIR}/run_the_server.sh

# Make it executable
chmod +x ${GRADIO_DIR}/run_the_server.sh

# Set up systemd services for both ComfyUI and Gradio
sudo bash -c "cat > /etc/systemd/system/comfyui.service" << EOL
[Unit]
Description=ComfyUI Server

[Service]
Type=simple
ExecStart=${COMFYUI_DIR}/run_the_server.sh

[Install]
WantedBy=multi-user.target
EOL

sudo bash -c "cat > /etc/systemd/system/gradio.service" << EOL
[Unit]
Description=Gradio Server

[Service]
Type=simple
ExecStart=${GRADIO_DIR}/run_the_server.sh

[Install]
WantedBy=multi-user.target
EOL

# Reload systemd to recognize the new services
sudo systemctl daemon-reload
sudo systemctl enable comfyui.service
sudo systemctl start comfyui.service

sudo systemctl enable gradio.service
sudo systemctl start gradio.service

# Print the IP addresses
echo "ComfyUI should be running locally at http://127.0.0.1:8188"
echo "Gradio should be accessible publicly at http://$PUBLIC_IP:7860"

echo "Setup completed."
