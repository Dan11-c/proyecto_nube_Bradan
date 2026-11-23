#!/bin/bash
# Proyecto 1 · Despliegue del servidor web de Librería Tinta
set -euo pipefail
export AWS_PAGER=""   # evita que la salida se abra en un visor y detenga el script

REGION="us-east-1"
SUBNET_ID="subnet-087af7414c862827c"   # libreria-publica
VPC_ID="vpc-0e08a295ca13fc186"     # libreria-vpc
MI_IP="213.0.87.102/32"       # tu IP pública (compruébala en TU navegador: https://checkip.amazonaws.com)
                              # No usar curl aquí: en CloudShell daría la IP de CloudShell, no la tuya
ALUMNO="Bradan Espla"
SG_NAME="libreria-web-cli-sg"

# La carpeta del script, para encontrar user-data1.sh aunque se ejecute desde otro sitio
DIR="$(cd "$(dirname "$0")" && pwd)"

echo "IP de administración (SSH): $MI_IP"

# 1. AMI más reciente de Amazon Linux 2023
AMI_ID=$(aws ssm get-parameters --region "$REGION" \
  --names /aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64 \
  --query "Parameters[0].Value" --output text)
echo "AMI: $AMI_ID"

# 2. Grupo de seguridad (si ya existe en la VPC, se reutiliza en vez de fallar con InvalidGroup.Duplicate)
SG_ID=$(aws ec2 describe-security-groups --region "$REGION" \
  --filters "Name=group-name,Values=$SG_NAME" "Name=vpc-id,Values=$VPC_ID" \
  --query "SecurityGroups[0].GroupId" --output text)

if [ "$SG_ID" = "None" ]; then
  SG_ID=$(aws ec2 create-security-group --region "$REGION" \
    --group-name "$SG_NAME" \
    --description "Web Libreria Tinta (CLI)" \
    --vpc-id "$VPC_ID" \
    --query "GroupId" --output text)
  echo "Grupo de seguridad creado: $SG_ID"

  # HTTP (80) desde cualquier origen
  aws ec2 authorize-security-group-ingress --region "$REGION" \
    --group-id "$SG_ID" --protocol tcp --port 80 --cidr 0.0.0.0/0 > /dev/null

  # SSH (22) solo desde MI_IP
  aws ec2 authorize-security-group-ingress --region "$REGION" \
    --group-id "$SG_ID" --protocol tcp --port 22 --cidr "$MI_IP" > /dev/null
else
  echo "El grupo $SG_NAME ya existe ($SG_ID): se reutiliza"
fi

# 3. Instancia
INSTANCE_ID=$(aws ec2 run-instances --region "$REGION" \
  --image-id "$AMI_ID" \
  --instance-type t3.micro \
  --key-name vockey \
  --subnet-id "$SUBNET_ID" \
  --security-group-ids "$SG_ID" \
  --user-data "file://$DIR/user-data1.sh" \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=libreria-web-cli},{Key=Proyecto,Value=P1},{Key=Alumno,Value=$ALUMNO}]" \
  --query "Instances[0].InstanceId" --output text)
echo "Instancia creada: $INSTANCE_ID"

# Esperar a que la instancia esté en estado running
echo "Esperando a que la instancia arranque..."
aws ec2 wait instance-running --region "$REGION" --instance-ids "$INSTANCE_ID"

# Obtener su IP pública
IP=$(aws ec2 describe-instances --region "$REGION" --instance-ids "$INSTANCE_ID" \
  --query "Reservations[0].Instances[0].PublicIpAddress" --output text)

echo "Instancia en ejecución. Espera 1-2 minutos a que nginx se instale."
echo "Abre en el navegador: http://$IP"
