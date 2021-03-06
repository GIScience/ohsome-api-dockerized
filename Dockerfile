# 1. Build stage
FROM adoptopenjdk/openjdk11:jdk-11.0.10_9-alpine-slim as build-stage

ENV TERM xterm-256color

ARG OHSOMEAPI_VERSION

WORKDIR /opt/app/

# System deps and get the ohsome-api repository data:
RUN apk add git bash maven && git clone https://github.com/GIScience/ohsome-api.git ./ && git fetch --all --tags

# Checkout version if provided
RUN if [ -z $OHSOMEAPI_VERSION ] || [ "$OHSOMEAPI_VERSION" = "latest" ] ; then echo Version not provided. Sticking to latest version.; else echo Version provided. Checkout $OHSOMEAPI_VERSION \
    && git checkout --quiet tags/$OHSOMEAPI_VERSION ; fi

# Make it executable
RUN mvn -DskipTests=true package

# 2. Preparation stage
FROM adoptopenjdk/openjdk11:jre-11.0.10_9-alpine as preparation-stage

WORKDIR /opt/

# Copy only needed target files
COPY --from=build-stage /opt/app/target/*.jar /opt/app/target/

# Copy the fallback data and entrypoint
COPY entrypoint.sh /opt/

# Bootstrap the app os and compress the folder afterwards to reduce the image size.
RUN echo Prepare the app folder. \
    && apk add maven xz pv curl \
    && rm -rf /var/cache/apk/* \
    && echo Download the fallback database covering Heidelberg, Germany. \
    && curl -LJO https://github.com/MichaelsJP/ohsome-api-dockerized/raw/main/fallback_data/fallback.tar.xz \
    && echo Extract the fallback data. \
    && tar -xf fallback.tar.xz \
    && echo Copy the fallback data to the app folder. \
    && mv -f fallback.oshdb.mv.db /opt/app/ \
    && echo Copy the correct *.jar file to the app folder. \
    && mv /opt/app/target/*.jar /opt/app/ohsome-api.jar \
    && echo Remove unneeded folders. \
    && rm -rf /opt/app/target \
    && echo Make the entrypoint executable. \
    && chmod +x /opt/entrypoint.sh \
    && echo Compress the app folder at highest compression rate and with as much cores as possible. This may still take some time. \
    && tar -cf - app/  | xz -e -9 -T 0 -c - > app.tar.xz \
    && echo Clean the build environment from unneeded files. \
    && rm -rf app/ fallback.tar.xz \
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
