#!/bin/bash
set -x 

# Set up logging
LOG_FILE="/var/log/prod-bashscript.log"
exec > >(tee -a "$LOG_FILE") 2>&1
echo "Script started at $(date)"





#defining our variables
AWSCLI_PATH='/usr/local/bin/aws'
INVENTORY_FILE='/etc/ansible/prod_hosts'
IPS_FILE='/etc/ansible/prod.lists'
ASG_NAME='auto-discov-prod-asg'
SSH_KEY_PATH='/home/ec2-user/.ssh/id_rsa'  # Fixed: Using full path instead of ~
WAIT_TIME=20

# Ensure directories exist
mkdir -p /etc/ansible
mkdir -p /home/ec2-user/.ssh
chown ec2-user:ec2-user /home/ec2-user/.ssh

#write our functions
#fetching the IPs
find_ips() {
    if ! $AWSCLI_PATH ec2 describe-instances \
    --filters "Name=tag:aws:autoscaling:groupName,Values=$ASG_NAME" \
    --query 'Reservations[*].Instances[*].NetworkInterfaces[*].PrivateIpAddress' \
    --output text > "$IPS_FILE"; then
        echo "ERROR: Failed to fetch IPs" | tee -a "$LOG_FILE"
        return 1
    fi
    echo "Successfully fetched IPs"
}

#update the inventory files
update_inventory() {
    echo "[webservers]" > "$INVENTORY_FILE" 
    while IFS= read -r instance; do
        if [ -z "$instance" ]; then
            continue
        fi
        ssh-keyscan -H "$instance" >> /home/ec2-user/.ssh/known_hosts 2>/dev/null
        echo "$instance ansible_user=ec2-user ansible_ssh_private_key_file=$SSH_KEY_PATH" >> "$INVENTORY_FILE"
    done < "$IPS_FILE"
    echo "Inventory updated successfully"
}

#wait for some minutes
wait_for_seconds() {
    echo "Waiting for $WAIT_TIME seconds..."
    sleep "$WAIT_TIME"
}

# check docker container status
check_docker_container() {
    while IFS= read -r instance; do
        if [ -z "$instance" ]; then
            continue
        fi
        
        if ! ssh -o StrictHostKeyChecking=no -i "$SSH_KEY_PATH" ec2-user@"$instance" "docker ps | grep appContainer" > /dev/null 2>&1; then
            echo "Container not running on $instance. Starting container..." | tee -a "$LOG_FILE"
            if ! ssh -o StrictHostKeyChecking=no -i "$SSH_KEY_PATH" ec2-user@"$instance" "bash /home/ec2-user/scripts/script.sh"; then
                echo "ERROR: Failed to start container on $instance" | tee -a "$LOG_FILE"
            fi
        else
            echo "Container is running on $instance." | tee -a "$LOG_FILE"
        fi
    done < "$IPS_FILE"
}

# Main function block
main() {
    echo "Starting main execution..."
    
    if ! find_ips; then
        exit 1
    fi
    
    if ! update_inventory; then
        exit 1
    fi
    
    wait_for_seconds
    
    if ! check_docker_container; then
        exit 1
    fi
    
    echo "Script completed successfully at $(date)"
}

# Execute main function
main

### End of script