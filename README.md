# cpvsDockerFIle
This repo maintains docker file for https://github.com/laeeq80/cpvsAPI. The docker file allows to create docker image for a single receptor. On deployment, each docker image creates a single independent service.

# Usage

Building docker container

docker build . -t username/cpvsAPI:receptorPDBID

# Practicalities

You will also need openbabel-2.4.1.tar.gz and cpvsapi-1.0.zip to successfully create docker container using this docker file. openbabel can be downloaded from https://sourceforge.net/projects/openbabel/files/openbabel/2.4.1/ whereas to create cpvsapi-1.0.zip, use https://github.com/laeeq80/cpvsAPI and run "sbt dist" command.

In the resources folder, one has to keep receptor file in PDBQT format, the vina conf.txt file and sig2Id file which can be created by our earlier project https://github.com/laeeq80/spark-cpvs-vina which also allows to create models used in https://github.com/laeeq80/cpvsAPI.

# ENV VARIABLE

Please set following env variables when launching the image

MARIADB_IP

CORS_URL 

RECEPTOR_NAME

RECEPTOR_PDBCODE
