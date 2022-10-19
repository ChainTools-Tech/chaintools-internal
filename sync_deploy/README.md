# state-sync node deployment script


## Pre-requisites
Before running deployment script make sure following tools are installed/available in the system:
 - jq
 - git
 - wget

Before installing node make sure user and home folder is created for particular node and then proper detailes are passed to script during execution.


## Script usage

Script deploys full chain node and configures statesync parametera as in chain profile.

Usage parameters: 
```bash
sync_deploy.sh -c <chain_name> -i <destination_folder> -o <service_owner> [-g]

Options:
   -c chain_name               name of chain configuration file, which will be used for deployment;
   -i destination_folder       folder where node will be installed (eg. /home/juno);
   -o service_owner            user and group which will be set on files and folders in destination;
   -g                          specifies, if golang should be installed;
```
In case of any questions contact support@chaintools.tech


## Expample execution
```bash
./sync_deploy.sh -c bitsong -g -o bitsong -i /home/bitsong
+----------------------------------------------------------------------------------------------------------------+
|    ____ _           _     _____           _                       _        _           _        _ _            |
|   / ___| |__   __ _(_)_ _|_   _|__   ___ | |___   _ __   ___   __| | ___  (_)_ __  ___| |_ __ _| | | ___ _ __  |
|  | |   | '_ \ / _' | | '_ \| |/ _ \ / _ \| / __| | '_ \ / _ \ / _' |/ _ \ | | '_ \/ __| __/ _' | | |/ _ \ '__| |
|  | |___| | | | (_| | | | | | | (_) | (_) | \__ \_| | | | (_) | (_| |  __/_| | | | \__ \ || (_| | | |  __/ |    |
|   \____|_| |_|\__,_|_|_| |_|_|\___/ \___/|_|___(_)_| |_|\___/ \__,_|\___(_)_|_| |_|___/\__\__,_|_|_|\___|_|    |
|                                                                                                                |
|                    _        _                                             _ _ _   _                            |
|                ___| |_ __ _| |_ ___       ___ _   _ _ __   ___    ___  __| (_) |_(_) ___  _ __                 |
|               / __| __/ _' | __/ _ \_____/ __| | | | '_ \ / __|  / _ \/ _' | | __| |/ _ \| '_ \                |
|               \__ \ || (_| | ||  __/_____\__ \ |_| | | | | (__  |  __/ (_| | | |_| | (_) | | | |               |
|               |___/\__\__,_|\__\___|     |___/\__, |_| |_|\___|  \___|\__,_|_|\__|_|\___/|_| |_|               |
|                                               |___/                                                            |
+----------------------------------------------------------------------------------------------------------------+
Preflight check.
= STARTING DEPLOYMENT =
Preparing environment.
-- Removing folder with GitHub cloned repo: /home/bitsong/bitsong.
-- Removing old node folder: /home/bitsong/.bitsongd.
-- Removing cosmos-sdk folder: /home/bitsong/cosmos-sdk.
Installing Golang.
-- Go environment:
---- GOROOT: /usr/local/go
---- GOPATH: /home/bitsong/go
---- GOBIN: /home/bitsong/go/bin
---- GOCACHE: /home/bitsong/.cache/go-build
---- GOVER: go1.19.2
Building Node.
-- Cloning repository: https://github.com/bitsongofficial/go-bitsong.
-- Checking out version: v0.11.0.
-- Building node binaries: bitsongd.
Building Cosmovisor.
-- Cloning Cosmovisor repo.
-- Building Cosmovisor.
-- Installing Cosmovisor binaries.
Initializing Node.
-- Downloading address book.
-- Downloading genesis.
-- Creating Cosmovisor folders and placing node binaries.
Initializing State Sync.
-- Pulling data from RPC server.
-- Adjusting node state-sync configuration.
Configuring service.
-- Generating service file.
-- Setting up and enabling service.
Setting foler/file ownership.
Finalizing deployment.
= DEPLOYMENT SUMMARY =
Chain ID: bitsong-2b
Git Repository: https://github.com/bitsongofficial/go-bitsong
Repository version: v0.11.0
Binary name: bitsongd
Installation folder: /home/bitsong
Folder owner: bitsong
Address book source: https://files.chaintools.tech/chains/bitsong/addrbook.json
Genesis source: https://github.com/bitsongofficial/networks/raw/master/bitsong-2b/genesis.json
Config folder: .bitsongd
RPC Server 1: https://rpc.bitsong.chaintools.tech:443
RPC Server 2: https://rpc.bitsong.chaintools.tech:443
Block offset: 2000
Statesync params: 8252321 8250321 729ED398096587054C1393A484DD17B16EEDA89F02DE27A5E3C108CF2DFF285A
```
