#!/bin/bash
source ~/passwd_variable.sh
sudo apt install s3cmd -y
s3cmd --version
echo "access_key = $id_key" > ~/.s3cfg
echo "secret_key = $secrets_key" >> ~/.s3cfg
echo "bucket_location = ru-central1" >> ~/.s3cfg 
echo "host_base = storage.yandexcloud.net" >> ~/.s3cfg
echo "host_bucket = %(bucket)s.storage.yandexcloud.net" >> ~/.s3cfg
echo "website_endpoint = http://%(bucket)s.website.yandexcloud.net" >> ~/.s3cfg
s3cmd ls
