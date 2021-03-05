# 1. Build stage
FROM adoptopenjdk/openjdk11:jdk-11.0.10_9-alpine-slim as build-stage

ENV TERM xterm-256color
ENV RED "\033[0;31m"
ENV GREEN "\033[0;32m"
ENV NC "\033[0m"

ARG OHSOMEAPI_VERSION

WORKDIR /opt/app/

# System deps and get the ohsome-api repository data:
RUN apk add git bash maven && git clone https://github.com/GIScience/ohsome-api.git ./ && git fetch --all --tags

# Checkout version if provided
RUN if [ -z $OHSOMEAPI_VERSION ] || [ "$OHSOMEAPI_VERSION" = "latest" ] ; then echo ${RED}Version not provided. Sticking to latest version.${NC} ; else echo ${GREEN}Version provided. Checkout $OHSOMEAPI_VERSION${NC} \
    && git checkout --quiet tags/$OHSOMEAPI_VERSION ; fi

# Make it executable
RUN mvn -DskipTests=true package

# 2. Production stage
FROM adoptopenjdk/openjdk11:jre-11.0.10_9-alpine as production-stage

ENV TERM xterm-256color
ENV RED "\033[0;31m"
ENV GREEN "\033[0;32m"
ENV NC "\033[0m"

# Fallback dataset if no data set is defined at container start
ARG FALLBACK_DATA_FILE

# Set author and maintainer information for proper contact details
LABEL author="Julian Psotta <julianpsotta@gmail.com>"
LABEL maintainer="Julian Psotta <julianpsotta@gmail.com>"

# System deps:
RUN apk add maven

WORKDIR /opt/app/

# Copy only needed target files
COPY --from=build-stage /opt/app/target /opt/app/target

# Copy whatever .jar target has been generated
RUN mv /opt/app/target/*.jar /opt/app/target/ohsome-api.jar

# Copy the fallback data with silent fail if it doesn't exist
COPY .blank $FALLBACK_DATA_FILE /opt/app/

# Create image with fallback data if valid else just continue
RUN if [ -z $FALLBACK_DATA_FILE ] ; then echo ${GREEN}fallback database not provided. Creating the image without one.${NC} ; else echo ${GREEN}Fallback database provided. Compressing and copying it to the image. This may take a while.${NC} \
    && mv -f $(basename $FALLBACK_DATA_FILE) /opt/app/fallback_database.oshdb.mv.db \
    && env GZIP=-9 tar cvzf fallback_database.tar.gz fallback_database.oshdb.mv.db\
    && rm -f $(basename $FALLBACK_DATA_FILE) .blank fallback_database.oshdb.mv.db; fi

# Add the entrypoint file
ADD ./entrypoint.sh /opt/app/entrypoint.sh

# Make the entrypoint script executable
RUN chmod +x entrypoint.sh

# Entrypoint run
CMD ["./entrypoint.sh"]
