# ohsome-api-dockerized

Dockerized Version of the ohsome-api. The current code of the `ohsome-api` can be found
at: [https://github.com/GIScience/ohsome-api](https://github.com/GIScience/ohsome-api).
To see all available docker images
visit: [julianpsotta/ohsome-api](https://hub.docker.com/repository/docker/julianpsotta/ohsome-api)
<!-- TOC -->

- [requirements](#requirements)
- [Usage](#usage)
    + [Run pre-build images](#run-pre-build-images)
        - [EXAMPLE: Simplest and quickest docker run with a fallback database build in](#example--simplest-and-quickest-docker-run-with-a-fallback-database-build-in)
        - [EXAMPLE: Docker run by using a custom database](#example--docker-run-by-using-a-custom-database)
        - [EXAMPLE: docker-compose run by using a custom database](#example--docker-compose-run-by-using-a-custom-database)
    + [Build images](#build-images)
        - [Download a fallback database (optional)](#download-a-fallback-database--optional-)
        - [EXAMPLE: Build the latest version with docker](#example--build-the-latest-version-with-docker)
        - [EXAMPLE: Build with docker-compose using version 1.3.2](#example--build-with-docker-compose-using-version-132)

<!-- /TOC -->

# requirements

- docker
- docker-compose

# Usage

Either use pre-build docker images or build the images yourself.

### Run pre-build images

If you wish to load a local database instead of using the fallback database (Heidelberg), you have to provide a
valid `*.oshdb.mv.db` file from [http://downloads.ohsome.org](http://downloads.ohsome.org) and load it as a volume into
the container as described below.
You can leave that folder empty to use the build in fallback database, covering
only [Heidelberg](http://downloads.ohsome.org/v0.6/europe/germany/baden-wuerttemberg/).
---

#### EXAMPLE: Simplest and quickest docker run with a fallback database build in

```shell
# docker image with pre-build images using a fallback database of heidelberg http://downloads.ohsome.org/v0.6/europe/germany/baden-wuerttemberg/
docker run -t -i --name ohsome-api -p 8080:8080 --env julianpsotta/ohsome-api:latest
```

---

#### EXAMPLE: Docker run by using a custom database

Pre-build docker images with a local database named `heidelberg_68900_2020-07-23.oshdb.mv.db` which should be copied
to `./data` for this example.
If the download fails, or you need a different database checkout: http://downloads.ohsome.org

```shell
curl -O http://downloads.ohsome.org/v0.6/europe/germany/baden-wuerttemberg/heidelberg_68900_2020-07-23.oshdb.mv.db
mkdir ./data && mv heidelberg_68900_2020-07-23.oshdb.mv.db ./data
docker run -t -i --name ohsome-api -p 8080:8080 -v "$(pwd)/data:/opt/app/data" --env DATA_FILE="heidelberg_68900_2020-07-23.oshdb.mv.db" julianpsotta/ohsome-api:1.3.2
# To see what happens inside the container run
docker logs -ft ohsome-api
```

---

#### EXAMPLE: docker-compose run by using a custom database

```shell
# docker-compose with pre-build images
curl -O http://downloads.ohsome.org/v0.6/europe/germany/baden-wuerttemberg/heidelberg_68900_2020-07-23.oshdb.mv.db
mkdir ./data && mv heidelberg_68900_2020-07-23.oshdb.mv.db ./data
docker-compose up -d
# To see what happens inside the container run
docker-compose logs -ft
```

Open the `docker-compose.yml` file in order to change details e.g. the Version you want to use.

### Build images

#### Download a fallback database (optional)

The fallback database is used for scenarios where no database is provided when the image is used to start a
container.
This database will be incorporated into the image itself thus increasing its size.
This is especially handy if you need a quick container to use in e.g. github workflows to test against a local api.
Consider a small data set like heidelberg:

```shell
curl -o fallback.oshdb.mv.db http://downloads.ohsome.org/v0.6/europe/germany/baden-wuerttemberg/heidelberg_68900_2020-07-23.oshdb.mv.db
```

---

#### EXAMPLE: Build the latest version with docker

```shell
docker build -t julianpsotta/ohsome-api:latest --build-arg OHSOMEAPI_VERSION=latest --build-arg FALLBACK_DATA_FILE=fallback.oshdb.mv.db .
```

---

#### EXAMPLE: Build with docker-compose using version 1.3.2

```shell
docker-compose -f docker-compose_build.yml build
```

Open the `docker-compose_build.yml` in order to change details e.g. the Version you want to build.
