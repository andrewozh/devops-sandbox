#!/bin/bash -xe

AWS_PROFILE=pritunl
CERTBOT_DIR=~ec2-user/certbot
LOG_FILE="${CERTBOT_DIR}/renew-cert.log"

exec &> >(tee -a "${LOG_FILE}")

function log {
  echo "`date` $@"
}

function err {
  log "$@"
  exit 1
}

[ -f `which aws` ] || log "ERROR: No aws-cli found!"
[ -f `which certbot` ] || log "ERROR: No certbot found!"
[ -f ~ec2-user/.aws/config ] || log "ERROR: No aws credentials found!"

AWS_PRITUNL_SGID="`aws ec2 describe-security-groups \
  --filter Name=group-name,Values=pritunl-vpn \
  --query 'SecurityGroups[*].[GroupId]' \
  --output text`"

aws ec2 authorize-security-group-ingress \
    --group-id ${AWS_PRITUNL_SGID} \
    --protocol tcp \
    --port 80 \
    --cidr 0.0.0.0/0

certbot certonly \
    -n -d 'common-vpn.drct.aero' \
    --work=dir=${CERTBOT_DIR} \
    --logs-dir=${CERTBOT_DIR} \
    --config-dir=${CERTBOT_DIR}\
    --agree-tos \
    --email devops@drct.aero \
    --dns-route53 \
    --post-hook "systemctl restart pritunl.service"

aws ec2 revoke-security-group-ingress \
    --group-id ${AWS_PRITUNL_SGID} \
    --protocol tcp \
    --port 80 \
    --cidr 0.0.0.0/0
