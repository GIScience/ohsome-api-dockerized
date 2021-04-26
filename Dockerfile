# 1. Build stage
FROM adoptopenjdk/openjdk11:jdk-11.0.10_9-alpine-slim as build-stage

ENV TERM xterm-256color

ARG OHSOMEAPI_VERSION

WORKDIR /opt/app/

# System deps and get the ohsome-api repository data:
RUN apk add git bash maven \
     && if [ -z $OHSOMEAPI_VERSION ] || [ "$OHSOMEAPI_VERSION" = "latest" ] ; then echo Version not provided. Sticking to latest version. && export BRANCH_PARAMETER=""; else echo Version provided. Checkout $OHSOMEAPI_VERSION && export BRANCH_PARAMETER="-b $OHSOMEAPI_VERSION"; fi  \
    && git clone https://github.com/GIScience/ohsome-api.git $BRANCH_PARAMETER --depth 1 .

COPY fallback_data/fallback.tar.xz /opt/app/

# Checkout version if provided
RUN echo Extract the test data. \
    && tar -xf fallback.tar.xz \
    && rm -rf fallback.tar.xz

RUN echo Build and run the integration tests \
    && mvn -DskipTests=false -Dport_get=8081 -Dport_post=8082 -Dport_data=8083 -DdbFilePathProperty="--database.db=./fallback.oshdb.mv.db" package


# 2. Preparation stage
FROM adoptopenjdk/openjdk11:jre-11.0.10_9-alpine as preparation-stage

WORKDIR /opt/

# Copy only needed target files
COPY --from=build-stage /opt/app/target/*.jar /opt/app/target/

# Copy the fallback data and entrypoint
COPY entrypoint.sh /opt/

# Bootstrap the app os and compress the folder afterwards to reduce the image size.
RUN echo Prepare the app folder. \
    && apk add maven xz \
    && rm -rf /var/cache/apk/* \
    && echo Copy the correct *.jar file to the app folder. \
    && mv /opt/app/target/*.jar /opt/app/ohsome-api.jar \
    && echo Remove unneeded folders. \
    && rm -rf /opt/app/target \
    && echo Make the entrypoint executable. \
    && chmod +x /opt/entrypoint.sh \
    && echo Compress the app folder at highest compression rate and with as much cores as possible. This may still take some time. \
    && tar -cf - app/  | xz -e -9 -T 0 -c - > app.tar.xz \
    && echo Clean the build environment from unneeded files. \
    && rm -rf app/ \
    && echo Done!

# 3. Production stage
FROM adoptopenjdk/openjdk11:jre-11.0.10_9-alpine as production-stage

WORKDIR /opt/

# Set author and maintainer information for proper contact details
LABEL author="Julian Psotta <julianpsotta@gmail.com>"
LABEL maintainer="Julian Psotta <julianpsotta@gmail.com>"

# Copy only needed target files
COPY --from=preparation-stage /opt/ /opt/

# Entrypoint run
CMD ["./entrypoint.sh"]
