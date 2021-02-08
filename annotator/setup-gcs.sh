############################################
## example docker-stacks/setup_envs.sh ##
############################################
echo ""
echo "Mount GCS bucket"
mkdir /home/jovyan/gcs
sudo gcsfuse -o nonempty -file-mode=777 -dir-mode=777 ${BUCKET} /home/jovyan/gcs

