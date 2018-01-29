	FROM java:openjdk-8-jre

        #Installing openbabel
        RUN apt-get update && apt-get install -y openbabel && apt-get -y clean
	
	### Setup user for build execution and application runtime
	ENV APP_ROOT=/opt/app-root
	ENV PATH=${APP_ROOT}/bin:${PATH} HOME=${APP_ROOT}
	COPY bin/ ${APP_ROOT}/bin/
	
	#Setting env variables
        ENV RESOURCES_HOME=${APP_ROOT}/resources/
        ENV VINA_DOCKING=${APP_ROOT}/bin/vina
        ENV VINA_CONF=${APP_ROOT}/resources/conf.txt
        ENV OBABEL_HOME=/usr/bin/obabel
        ENV SBT_OPTS="-Xmx2G -XX:+UseConcMarkSweepGC -XX:+CMSClassUnloadingEnabled -Xss2M"
        ENV JAVA_OPTS="-Xms512m -Xmx2g"
	ENV MARIADB_IP=172.17.0.2	

	#COPY ALL REQUIRED RESOURCES TO DOCKER IMAGE
        COPY ./resources ${APP_ROOT}/resources		
	
	# Moving my distribution to docker image
        COPY ./cpvsapi-1.0.zip ${APP_ROOT}/bin
	RUN cd ${APP_ROOT}/bin && unzip ${APP_ROOT}/bin/cpvsapi-1.0.zip && chmod u+x ${APP_ROOT}/bin/cpvsapi-1.0/bin/cpvsapi && rm ${APP_ROOT}/bin/cpvsapi-1.0.zip		

	RUN chmod -R u+x ${APP_ROOT}/bin && \
    		chgrp -R 0 ${APP_ROOT} && \
    		chmod -R g=u ${APP_ROOT} /etc/passwd

	### Containers should NOT run as root as a good practice
	USER 10001
	WORKDIR ${APP_ROOT}

	### user name recognition at runtime w/ an arbitrary uid - for OpenShift deployments
	ENTRYPOINT [ "uid_entrypoint" ]
	EXPOSE 9000
	CMD run
