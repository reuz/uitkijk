#!/usr/bin/env bash
# Install script for Uitkijk, runs inside the container (community-scripts style).
# Source: https://github.com/reuz/uitkijk
source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

GH_REPO="${GH_REPO:-reuz/uitkijk}"
GH_BRANCH="${GH_BRANCH:-main}"

msg_info "Installing Dependencies"
$STD apt-get install -y git curl ca-certificates
msg_ok "Installed Dependencies"

msg_info "Fetching ${GH_REPO}"
rm -rf /opt/camera-service
$STD git clone --branch "$GH_BRANCH" --single-branch "https://github.com/${GH_REPO}.git" /opt/camera-service
msg_ok "Fetched ${GH_REPO}"

msg_info "Installing Uitkijk (a few minutes)"
mkdir -p /clips
$STD env REPO="$GH_REPO" BRANCH="$GH_BRANCH" EXPORT_MODEL="${EXPORT_MODEL:-1}" CORAL="${CORAL:-auto}" \
  bash /opt/camera-service/deploy/lxc/install.sh
msg_ok "Installed Uitkijk"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"
