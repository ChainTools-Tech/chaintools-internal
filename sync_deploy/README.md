# state-sync node deployment script

Script deploys full chain node using state-sync.
Steps of deployment:


Usage: 
```bash
sync_deploy.sh -c <chain_name> -i <destination_folder> -o <service_owner> [-g]

Options:
   -c chain_name               name of chain configuration file, which will be used for deployment;
   -i destination_folder       folder where node will be installed (eg. /home/juno);
   -o service_owner            user and group which will be set on files and folders in destination;
   -g                          specifies, if golang should be installed;
```
In case of any questions contact support@chaintools.tech