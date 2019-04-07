	FROM java:openjdk-8-jre

        #Installing blas
        RUN apt-get update && apt-get install -y libatlas3-base libopenblas-base && apt-get -y clean	
	
	### Setup user for build execution and application runtime
	ENV APP_ROOT=/opt/app-root
	ENV PATH=${APP_ROOT}/bin:${PATH} HOME=${APP_ROOT}
	COPY bin/ ${APP_ROOT}/bin/
	
	#Setting env variables
        ENV PATH=$PATH:${APP_ROOT}/openbabel/
	ENV RESOURCES_HOME=${APP_ROOT}/resources/
        ENV VINA_DOCKING=${APP_ROOT}/bin/vina
        ENV VINA_CONF=${APP_ROOT}/resources/conf.txt
        ENV OBABEL_HOME=${APP_ROOT}/bin/build/bin/obabel
        ENV SBT_OPTS="-Xmx2G -XX:+UseConcMarkSweepGC -XX:+CMSClassUnloadingEnabled -Xss2M"
        ENV JAVA_OPTS="-Xms512m -Xmx2g"
	
	#COPY ALL REQUIRED RESOURCES TO DOCKER IMAGE
        COPY ./resources ${APP_ROOT}/resources

	#Solving issues with jessi
	RUN echo "deb [check-valid-until=no] http://archive.debian.org/debian jessie main" > /etc/apt/sources.list.d/jessie-backports.list
	RUN sed -i '/deb http:\/\/deb.debian.org\/debian jessie-updates main/d' /etc/apt/sources.list
	RUN apt-get -o Acquire::Check-Valid-Until=false update
	
	#Moving openbabel 2.4.1 tar file to docker image and install it
	COPY ./openbabel-2.4.1.tar.gz ${APP_ROOT}/bin
	RUN apt-get update && apt-get install -y gcc && apt-get install -y cmake && apt-get -y clean
	RUN cd ${APP_ROOT}/bin && tar -zxf openbabel-2.4.1.tar.gz && mkdir build && cd build && apt-get install -y build-essential && cmake ../openbabel-2.4.1 -DCMAKE_INSTALL_PREFIX=~/Tools && make -j4 && make install && rm ${APP_ROOT}/bin/openbabel-2.4.1.tar.gz 		
	
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
