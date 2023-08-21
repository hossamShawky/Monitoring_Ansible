#! /usr/bin/bash

# Populate Inventory

ip=$(aws ec2 describe-instances \
--filters "Name=tag:env,Values=prometheus" "Name=instance-state-name,Values=running" \
--query 'Reservations[*].Instances[*].PublicIpAddress' \
--output text)


cat > inventory <<EOF
[prometheus]
$ip

EOF

echo "The inventory has been updated!"
echo "Starting Playbook Now..."

ansible-playbook playbook.yml --ask-vault-pass 

echo "You can access Prometheus dashboard on: "
echo "http://"$ip:9090

echo "You can access NodeExporter dashboard on: "
echo "https://"$ip:9100

echo "You can access Grafanaa dashboard on: "
echo "http://"$ip:3000

