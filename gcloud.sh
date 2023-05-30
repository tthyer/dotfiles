#! /bin/bash

#TODO: find way to find latest version w/o hard-coding this from
#https://cloud.google.com/sdk/docs/install
archive=google-cloud-cli-431.0.0-darwin-arm.tar.gz
download_dir=${HOME}/Downloads
wget https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/${archive} \
  -P ${download_dir}
google_dir=${HOME}/.gcloud
mkdir -p ${google_dir}
tar -zxf ${download_dir}/${archive} --directory ${google_dir}
bash ${google_dir}/google-cloud-sdk/install.sh
gcloud init
gcloud components install kubectl -q
