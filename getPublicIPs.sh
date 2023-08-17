#! /usr/bin/bash

# Populate Inventory

prometheus=$(aws ec2 describe-instances \
--filters "Name=tag:env,Values=prometheus" "Name=instance-state-name,Values=running" \
--query 'Reservations[*].Instances[*].PublicIpAddress' \
--output text)


cat > inventory <<EOF
[prometheus]
$prometheus

EOF

echo "The inventory has been updated!"
echo "Starting Playbook Now..."

#ansible-playbook playbook.yml --ask-vault-pass

echo "You can access Prometheus dashboard on: "
echo "http://"$prometheus:9090
