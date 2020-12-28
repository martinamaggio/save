#!/usr/bin/env bash

wget https://gitlab.com/jamieoglindsey0/python-video-converter/-/archive/1.0.3/python-video-converter-1.0.3.tar.gz

tar -xzvf python-video-converter-1.0.3.tar.gz

cd python-video-converter-1.0.3

sudo python3 setup.py install

echo "Copying converter module"
cp -vr converter ../../

echo "Copying test video files"
cp -vr test ../../to_convert

rm ../../to_convert/logo.png ../../to_convert/test.py

cd ..

echo "Cleaning up"
sudo rm -rf python-converter-*

echo "Done!"