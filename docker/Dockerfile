# 
# https://stackoverflow.com/questions/18136389/using-ssh-keys-inside-docker-container/48262959#48262959
FROM  node:carbon as source

ARG SSH_KEY

# Authorize SSH Host
RUN mkdir -p /root/.ssh && \
    chmod 0700 /root/.ssh && \
    ssh-keyscan github.com > /root/.ssh/known_hosts && \
    echo "${SSH_KEY}" > /root/.ssh/id_rsa && \
    chmod 600 /root/.ssh/id_rsa

ARG T_VERSION  

RUN git clone -b "${T_VERSION}" --single-branch --depth 1 git@github.com:LABSS/PROTON-T.git

# Stage 2: build minified production code

FROM openjdk:8-jdk AS production
COPY --from=netlogobase:latest /opt/netlogo /opt/netlogo
COPY --from=source /PROTON-T/ /PROTON-T/

ARG T_VERSION  
ENV VERSION "${T_VERSION}"
RUN echo $_VERSION

WORKDIR /PROTON-T
#
#CMD /PROTON-T/docker/runit-T.sh $VERSION
CMD /extdisk/runit-T.sh $VERSION

