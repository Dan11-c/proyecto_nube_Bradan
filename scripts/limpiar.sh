#!/bin/bash
# Borra lo que crea desplegar.sh (instancia libreria-web-cli y grupo libreria-web-cli-sg)
# NO toca los recursos del nivel básico.
set -euo pipefail
export AWS_PAGER=""

REGION="us-east-1"
SG_NAME="libreria-web-cli-sg"

IDS=$(aws ec2 describe-instances --region "$REGION" \
  --filters "Name=tag:Name,Values=libreria-web-cli" "Name=instance-state-name,Values=pending,running,stopping,stopped" \
  --query "Reservations[].Instances[].InstanceId" --output text)

if [ -n "$IDS" ]; then
  echo "Terminando instancias: $IDS"
  aws ec2 terminate-instances --region "$REGION" --instance-ids $IDS > /dev/null
  aws ec2 wait instance-terminated --region "$REGION" --instance-ids $IDS
else
  echo "No hay instancias libreria-web-cli"
fi

SG_ID=$(aws ec2 describe-security-groups --region "$REGION" \
  --filters "Name=group-name,Values=$SG_NAME" \
  --query "SecurityGroups[0].GroupId" --output text)

if [ "$SG_ID" != "None" ]; then
  echo "Borrando grupo de seguridad $SG_ID"
  aws ec2 delete-security-group --region "$REGION" --group-id "$SG_ID"
else
  echo "No existe el grupo $SG_NAME"
fi

echo "Limpieza terminada"
