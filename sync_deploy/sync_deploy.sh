#!/bin/bash

# Terminal color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

LOG_FILE=sync_deploy.log
BASEDIR=$(dirname "$0")
INSTALL_GOLANG=false



function welcome_screen() {
	echo -e "+----------------------------------------------------------------------------------------------------------------+"
	echo -e "|    ____ _           _     _____           _                       _        _           _        _ _            |"
	echo -e "|   / ___| |__   __ _(_)_ _|_   _|__   ___ | |___   _ __   ___   __| | ___  (_)_ __  ___| |_ __ _| | | ___ _ __  |"
	echo -e "|  | |   | '_ \ / _' | | '_ \| |/ _ \ / _ \| / __| | '_ \ / _ \ / _' |/ _ \ | | '_ \/ __| __/ _' | | |/ _ \ '__| |"
	echo -e "|  | |___| | | | (_| | | | | | | (_) | (_) | \__ \_| | | | (_) | (_| |  __/_| | | | \__ \ || (_| | | |  __/ |    |"
	echo -e "|   \____|_| |_|\__,_|_|_| |_|_|\___/ \___/|_|___(_)_| |_|\___/ \__,_|\___(_)_|_| |_|___/\__\__,_|_|_|\___|_|    |"
	echo -e "|                                                                                                                |"
	echo -e "|                    _        _                                             _ _ _   _                            |"
	echo -e "|                ___| |_ __ _| |_ ___       ___ _   _ _ __   ___    ___  __| (_) |_(_) ___  _ __                 |"
	echo -e "|               / __| __/ _' | __/ _ \_____/ __| | | | '_ \ / __|  / _ \/ _' | | __| |/ _ \| '_ \                |"
	echo -e "|               \__ \ || (_| | ||  __/_____\__ \ |_| | | | | (__  |  __/ (_| | | |_| | (_) | | | |               |"
	echo -e "|               |___/\__\__,_|\__\___|     |___/\__, |_| |_|\___|  \___|\__,_|_|\__|_|\___/|_| |_|               |"
	echo -e "|                                               |___/                                                            |"
	echo -e "+----------------------------------------------------------------------------------------------------------------+"
}


# Initializes deployment
function initialize_deployment() {
	echo -e "${RED}= STARTING DEPLOYMENT =${NC}"
	echo -e "${GREEN}Preparing environment.${NC}"

	if [ -d ${DEST_DIR}/${CHAIN_NAME} ]; then
		echo -e "${BLUE}-- Removing folder with GitHub cloned repo: ${DEST_DIR}/${CHAIN_NAME}."
		rm -rf ${DEST_DIR}/${CHAIN_NAME}
	fi

	if [ -d ${DEST_DIR}/${CONFIG_FOLDER} ]; then
		echo -e "${BLUE}-- Removing old node folder: ${DEST_DIR}/${CONFIG_FOLDER}."
		rm -rf ${DEST_DIR}/${CONFIG_FOLDER}
	fi

	if [ -d ${DEST_DIR}/cosmos-sdk ]; then
		echo -e "${BLUE}-- Removing cosmos-sdk folder: ${DEST_DIR}/cosmos-sdk."
		rm -rf ${DEST_DIR}/cosmos-sdk
	fi

	GOPATH_ORIG=${GOPATH}
	GOBIN_ORIG=${GOBIN}
	GOCACHE_ORIG=${GOCACHE}
	
	export GOPATH=${DEST_DIR}/go
	export GOBIN=${DEST_DIR}/go/bin
	export GOCACHE=${DEST_DIR}/.cache/go-build

}


# Check if all parameters passed to script are correct
function preflight_check() {
	echo -e "${GREEN}Preflight check.${NC}"
}


# Install latest Golang
function install_golang() {
	echo -e "${GREEN}Installing Golang.${NC}"
	GOVER=$(curl -s https://go.dev/VERSION?m=text) &> /dev/null
	rm -rf ${GOVER}.linux-amd64.tar.gz &> /dev/null
	wget https://golang.org/dl/${GOVER}.linux-amd64.tar.gz &> /dev/null
	rm -rf /usr/local/go && sudo tar -C /usr/local -xzf ${GOVER}.linux-amd64.tar.gz && rm -rf ${GOVER}.linux-amd64.tar.gz &> /dev/null
	export GOROOT=/usr/local/go &> /dev/null
   export PATH=${PATH}:${GOROOT}/bin:${GOBIN} &> /dev/null
   echo -e "${BLUE}-- Go environment:${NC}"
   echo -e "${BLUE}---- GOROOT:${NC} ${GOROOT}"
   echo -e "${BLUE}---- GOPATH:${NC} ${GOPATH}"
   echo -e "${BLUE}---- GOBIN:${NC} ${GOBIN}"
   echo -e "${BLUE}---- GOCACHE:${NC} ${GOCACHE}"
   echo -e "${BLUE}---- GOVER:${NC} ${GOVER}"
}

# Build node binaries
function build_node() {
	echo -e "${GREEN}Building Node.${NC}"
	echo -e "${BLUE}-- Cloning repository:${NC} ${GIT_REPO}."
	git clone ${GIT_REPO} ${DEST_DIR}/${CHAIN_NAME} &> /dev/null
	cd ${DEST_DIR}/${CHAIN_NAME} &> /dev/null
	echo -e "${BLUE}-- Checking out version:${NC} ${GIT_VERSION}."
	git checkout ${GIT_VERSION} &> /dev/null
	echo -e "${BLUE}-- Building node binaries:${NC} ${BIN_NAME}."
	make install &> /dev/null
}


# Build Cosmovisor binaries
function build_cosmovisor() {
	echo -e "${GREEN}Building Cosmovisor.${NC}"
	cd ${DEST_DIR}
	echo -e "${BLUE}-- Cloning Cosmovisor repo.${NC}"
	git clone https://github.com/cosmos/cosmos-sdk &> /dev/null
	cd ${DEST_DIR}/cosmos-sdk/cosmovisor/ &> /dev/null
	echo -e "${BLUE}-- Building Cosmovisor."
	make cosmovisor &> /dev/null
	echo -e "${BLUE}-- Installing Cosmovisor binaries.${NC}"
	mkdir -p ${DEST_DIR}/.local/bin &> /dev/null
	cp ${DEST_DIR}/cosmos-sdk/cosmovisor/cosmovisor ${DEST_DIR}/.local/bin &> /dev/null
}


# Creates basic configuration for node, downloads genesis and address book
function initialize_node() {
	echo -e "${GREEN}Initializing Node.${NC}"
	${GOPATH}/bin/${BIN_NAME} init myNode --chain-id ${CHAIN_ID} --home ${DEST_DIR}/${CONFIG_FOLDER} &> /dev/null
	echo -e "${BLUE}-- Downloading address book.${NC}"
	wget ${URL_ADDRBOOK} -O ${DEST_DIR}/${CONFIG_FOLDER}/config/addrbook.json &> /dev/null
	echo -e "${BLUE}-- Downloading genesis.${NC}"
	wget ${URL_GENESIS} -O ${DEST_DIR}/${CONFIG_FOLDER}/config/genesis.json &> /dev/null
	echo -e "${BLUE}-- Creating Cosmovisor folders and placing node binaries.${NC}"
	mkdir -p ${DEST_DIR}/${CONFIG_FOLDER}/cosmovisor/genesis/bin &> /dev/null
	cp ${GOPATH}/bin/${BIN_NAME} ${DEST_DIR}/${CONFIG_FOLDER}/cosmovisor/genesis/bin &> /dev/null
}


# Pulls data from RPC server and sets initial parameters for state-sync in config.toml
function initialize_state_sync() {
	echo -e "${GREEN}Initializing State Sync.${NC}"
	echo -e "${BLUE}-- Pulling data from RPC server.${NC}"
	LATEST_HEIGHT=$(curl -s ${SNAP_RPC1}/block | jq -r .result.block.header.height); \
	BLOCK_HEIGHT=$((${LATEST_HEIGHT} - ${BLOCK_OFFSET})); \
	TRUST_HASH=$(curl -s "${SNAP_RPC1}/block?height=${BLOCK_HEIGHT}" | jq -r .result.block_id.hash)
	echo -e "${BLUE}-- Adjusting node state-sync configuration.${NC}"
	sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
	s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"${SNAP_RPC1},${SNAP_RPC2}\"| ; \
	s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1${BLOCK_HEIGHT}| ; \
	s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"${TRUST_HASH}\"| ; \
	s|^(seeds[[:space:]]+=[[:space:]]+).*$|\1\"\"|" ${DEST_DIR}/${CONFIG_FOLDER}/config/config.toml
}


# Generates service file for systemd
function generate_service_file() {
	echo -e "${GREEN}Configuring service.${NC}"
	echo -e "${BLUE}-- Generating service file.${NC}"	
	echo "[Unit]" > ${DEST_DIR}/${CHAIN_NAME}.service
	echo "Description=Chain Node Name" >> ${DEST_DIR}/${CHAIN_NAME}.service
	echo "After=network-online.target" >> ${DEST_DIR}/${CHAIN_NAME}.service
	echo "" >> ${DEST_DIR}/${CHAIN_NAME}.service
	echo "[Service]" >> ${DEST_DIR}/${CHAIN_NAME}.service
	echo "User=${FOLDER_OWNER}" >> ${DEST_DIR}/${CHAIN_NAME}.service
	echo "Group=${FOLDER_OWNER}" >> ${DEST_DIR}/${CHAIN_NAME}.service
	echo "ExecStart=${DEST_DIR}/.local/bin/cosmovisor run start" >> ${DEST_DIR}/${CHAIN_NAME}.service
	echo "Restart=always" >> ${DEST_DIR}/${CHAIN_NAME}.service
	echo "RestartSec=3" >> ${DEST_DIR}/${CHAIN_NAME}.service
	echo "LimitNOFILE=4096" >> ${DEST_DIR}/${CHAIN_NAME}.service
	echo "Environment=\"DAEMON_NAME=${BIN_NAME}\"" >> ${DEST_DIR}/${CHAIN_NAME}.service
	echo "Environment=\"DAEMON_HOME=${DEST_DIR}/${CONFIG_FOLDER}\"" >> ${DEST_DIR}/${CHAIN_NAME}.service
	echo "Environment=\"DAEMON_ALLOW_DOWNLOAD_BINARIES=false\"" >> ${DEST_DIR}/${CHAIN_NAME}.service
	echo "Environment=\"DAEMON_RESTART_AFTER_UPGRADE=true\"" >> ${DEST_DIR}/${CHAIN_NAME}.service
	echo "Environment=\"DAEMON_LOG_BUFFER_SIZE=512\"" >> ${DEST_DIR}/${CHAIN_NAME}.service
	echo "Environment=\"UNSAFE_SKIP_BACKUP=true\"" >> ${DEST_DIR}/${CHAIN_NAME}.service
	echo "" >> ${DEST_DIR}/${CHAIN_NAME}.service
	echo "[Install]" >> ${DEST_DIR}/${CHAIN_NAME}.service
	echo "WantedBy=multi-user.target" >> ${DEST_DIR}/${CHAIN_NAME}.service
	echo -e "${BLUE}-- Setting up and enabling service.${NC}"
	cp ${DEST_DIR}/${CHAIN_NAME}.service /etc/systemd/system &> /dev/null
	systemctl daemon-reload
	systemctl enable ${CHAIN_NAME}.service &> /dev/null
}


# Changes ownership of files in destination folder
function set_file_ownership() {
    echo -e "${GREEN}Setting foler/file ownership.${NC}"
    chown -R -H ${FOLDER_OWNER}:${FOLDER_OWNER} ${DEST_DIR}
}


# Cleaning up environment post-deployment
function finalize_deployment() {
	echo -e "${GREEN}Finalizing deployment.${NC}"
	export GOPATH=${GOPATH_ORIG}
	export GOBIN=${GOBIN_ORIG}
	export GOCACHE=${GOCACHE_ORIG}
}


# Display deployment details
function display_debug() {
	echo -e "${RED}= DEPLOYMENT SUMMARY =${NC}"
	echo -e "${GREEN}Chain ID:${NC} ${CHAIN_ID}"
	echo -e "${GREEN}Git Repository:${NC} ${GIT_REPO}"
	echo -e "${GREEN}Repository version:${NC} ${GIT_VERSION}"
	echo -e "${GREEN}Binary name:${NC} ${BIN_NAME}"
	echo -e "${GREEN}Installation folder:${NC} ${DEST_DIR}"
	echo -e "${GREEN}Folder owner:${NC} ${FOLDER_OWNER}"
	echo -e "${GREEN}Address book source:${NC} ${URL_ADDRBOOK}"
	echo -e "${GREEN}Genesis source:${NC} ${URL_GENESIS}"
	echo -e "${GREEN}Config folder:${NC} ${CONFIG_FOLDER}"
	echo -e "${GREEN}RPC Server 1:${NC} ${SNAP_RPC1}"
	echo -e "${GREEN}RPC Server 2:${NC} ${SNAP_RPC2}"
	echo -e "${GREEN}Block offset:${NC} ${BLOCK_OFFSET}"
	echo -e "${GREEN}Statesync params:${NC} ${LATEST_HEIGHT} ${BLOCK_HEIGHT} ${TRUST_HASH}"
}


# Display script usage instructions
function display_help() {
	echo -e "${GREEN}${0##*/}${NC} - state-sync node deployment script"
	echo -e ""
	echo "Usage: ${0##*/} -c <chain_name> -i <destination_folder> -o <service_owner> [-g]"
   echo -e ""
   echo -e "Options:"
   echo -e "  -c chain_name               name of chain configuration file, which will be used for deployment;"
   echo -e "  -i destination_folder       folder where node will be installed (eg. /home/juno);"
   echo -e "  -o service_owner            user and group which will be set on files and folders in destination;"
   echo -e "  -g                          specifies, if golang should be installed;"
   echo -e ""
   echo -e "${RED}In case of any questions contact support@chaintools.tech${NC}"
}


while getopts ":c:i:o:g" opt; do
    case ${opt} in
        c )
           CHAIN_NAME=${OPTARG}
           ;;
        i )
           DEST_DIR=${OPTARG}
           ;;
        o )
           FOLDER_OWNER=${OPTARG}
           ;;
        g )
           INSTALL_GOLANG=true
           ;;
        h ) 
           display_help
           exit 0
           ;;
        \? )
           echo "Invalid option: -${OPTARG}"
           display_help
           exit 1
           ;;
    esac
done

. ${BASEDIR}/${CHAIN_NAME}.env

welcome_screen
preflight_check
initialize_deployment

if [ "${INSTALL_GOLANG}" = true ]; then
	install_golang
fi

build_node
build_cosmovisor
initialize_node
initialize_state_sync
generate_service_file
set_file_ownership
finalize_deployment
display_debug
