#!/usr/bin/env bash
# community-scripts style CT script for Uitkijk (fork of lexi1986/uitwijk, repo: reuz/uitkijk).
# Run on the Proxmox HOST:
#   bash -c "$(curl -fsSL https://raw.githubusercontent.com/reuz/uitkijk/main/deploy/lxc/uitkijk.sh)"
#
# Mirrors the community-scripts layout (ct/ + install/). The engine (build.func) lives in
# community-scripts/core; the script root (where install/uitkijk-install.sh is looked up)
# is pointed at this repo via COMMUNITY_SCRIPTS_URL.
GH_REPO="${GH_REPO:-reuz/uitkijk}"
GH_BRANCH="${GH_BRANCH:-main}"
export COMMUNITY_SCRIPTS_URL="${COMMUNITY_SCRIPTS_URL:-https://raw.githubusercontent.com/${GH_REPO}/${GH_BRANCH}}"
COMMUNITY_SCRIPTS_CORE_URL="${COMMUNITY_SCRIPTS_CORE_URL:-https://raw.githubusercontent.com/community-scripts/core/main}"
source <(curl -fsSL "${COMMUNITY_SCRIPTS_CORE_URL}/core/build.func") || { echo "Could not fetch build.func" >&2; exit 1; }
# Source: https://github.com/reuz/uitkijk
APP="Uitkijk"
var_tags="${var_tags:-camera;nvr;ai}"
var_cpu="${var_cpu:-2}"
var_ram="${var_ram:-4096}"
var_disk="${var_disk:-8}"
var_os="${var_os:-debian}"
var_version="${var_version:-12}"
var_unprivileged="${var_unprivileged:-1}"

export GH_REPO GH_BRANCH

header_info "$APP"
variables
color
catch_errors

function update_script() {
  header_info
  check_container_storage
  check_container_resources
  if [[ ! -d /opt/camera-service ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi
  msg_info "Updating ${APP}"
  if [[ -x /usr/local/bin/camera-service-update ]]; then
    /usr/local/bin/camera-service-update
  else
    git -C /opt/camera-service fetch -q origin "$GH_BRANCH"
    git -C /opt/camera-service reset -q --hard "origin/$GH_BRANCH"
    /opt/camera-service/.venv/bin/pip install -q -r /opt/camera-service/requirements.txt
    cp /opt/camera-service/deploy/camera-service.service /etc/systemd/system/camera-service.service
    systemctl daemon-reload
    systemctl restart camera-service
  fi
  msg_ok "Updated ${APP}"
  exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Open the web page and run the setup wizard:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:8080${CL}"
echo -e "${INFO}${YW} Setup code: pct exec ${CTID} -- journalctl -u camera-service | grep 'setup code'${CL}"
echo -e "${INFO}${YW} Clip disk, iGPU and Coral passthrough: see deploy/lxc/proxmox-create.sh${CL}"
