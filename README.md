# ohsome-api-dockerized

[![status: experimental](https://github.com/GIScience/badges/raw/master/status/experimental.svg)](https://github.com/GIScience/badges#experimental)

Dockerized Version of the ohsome-api. The current code of the `ohsome-api` can be found
at: [https://github.com/GIScience/ohsome-api](https://github.com/GIScience/ohsome-api). To see all available docker
images visit: [julianpsotta/ohsome-api](https://hub.docker.com/repository/docker/julianpsotta/ohsome-api)
<!-- TOC -->

# Table of contents

- [ohsome-api-dockerized](#ohsome-api-dockerized)
- [requirements](#requirements)
- [Usage](#usage)
    - [Run pre-build images](#run-pre-build-images)
    - [Build images](#build-images)
- [Contribute](#contribute)
- [Authors](#authors)
- [License](#license)
<!-- /TOC -->

# requirements

- docker
- docker-compose

# Usage

Either use pre-build docker images or build the images yourself.

### Run pre-build images

If you wish to load a local database instead of using the fallback database (Heidelberg), you have to provide a
valid `*.oshdb.mv.db` file from [http://downloads.ohsome.org](http://downloads.ohsome.org) and load it as a volume into
the container as described below. You can leave that folder empty to use the build in fallback database,
covering [Heidelberg](http://downloads.ohsome.org/v0.6/europe/germany/baden-wuerttemberg/).

#### EXAMPLE: Simplest and quickest docker run with a fallback database build in

```shell
# docker image with pre-build images using a fallback database of heidelberg http://downloads.ohsome.org/v0.6/europe/germany/baden-wuerttemberg/
docker run -dt --name ohsome-api -p 8080:8080 julianpsotta/ohsome-api:latest

# Try the api with an actual request
curl -X POST "http://localhost:8080/contributions/latest/geometry?bboxes=8.67%2C49.39%2C8.71%2C49.42&clipGeometry=true&filter=type%3Away%20and%20natural%3D*&properties=tags&time=2016-01-01%2C2017-01-01" -H "accept: application/json"

```

---

#### EXAMPLE: Docker run by using a custom database

Pre-build docker images with a local database named `heidelberg_68900_2020-07-23.oshdb.mv.db` which should be copied
to `./data` for this example. If the download fails, or you need a different database
checkout: http://downloads.ohsome.org

```shell
curl -O http://downloads.ohsome.org/v0.6/europe/germany/baden-wuerttemberg/heidelberg_68900_2020-07-23.oshdb.mv.db
mkdir ./data && mv heidelberg_68900_2020-07-23.oshdb.mv.db ./data
docker run -dt --name ohsome-api -p 8080:8080 -v "$(pwd)/data:/opt/data" --env DATA_FILE="heidelberg_68900_2020-07-23.oshdb.mv.db" julianpsotta/ohsome-api:1.3.2
# To see what happens inside the container run
docker logs -ft ohsome-api
# Try the api with an actual request
curl -X POST "http://localhost:8080/contributions/latest/geometry?bboxes=8.67%2C49.39%2C8.71%2C49.42&clipGeometry=true&filter=type%3Away%20and%20natural%3D*&properties=tags&time=2016-01-01%2C2017-01-01" -H "accept: application/json"
```

---

#### EXAMPLE: docker-compose run by using a custom database

Use the provided `docker-compose.yml` or create one with a similar content:

```text
version: '2.1'
networks:
  ohsome:
    name: ohsome

services:
  ohsome-api:
    image: julianpsotta/ohsome-api:1.3.2
    container_name: ohsome-api
    environment:
      DATA_FILE: "your-database.oshdb.mv.db"
    volumes:
      - ./data:/opt/data
    ports:
      - 8080:8080
    restart: always
    networks:
      - ohsome
```

```shell
# docker-compose with pre-build images
curl -O http://downloads.ohsome.org/v0.6/europe/germany/baden-wuerttemberg/heidelberg_68900_2020-07-23.oshdb.mv.db
mkdir ./data && mv heidelberg_68900_2020-07-23.oshdb.mv.db ./data
docker-compose up -d
# To see what happens inside the container run
docker-compose logs -ft
# Try the api with an actual request
curl -X POST "http://localhost:8080/contributions/latest/geometry?bboxes=8.67%2C49.39%2C8.71%2C49.42&clipGeometry=true&filter=type%3Away%20and%20natural%3D*&properties=tags&time=2016-01-01%2C2017-01-01" -H "accept: application/json"
```

Open the `docker-compose.yml` file in order to change details e.g. the Version you want to use.

### Build images

The Dockerfile is always build with Heidelberg as a fallback database. The data itself is highly compressed and is not
adding much on the overall image size.

#### EXAMPLE: Build the latest version with docker

```shell
docker build -t julianpsotta/ohsome-api:latest --build-arg OHSOMEAPI_VERSION=latest .
```

---

#### EXAMPLE: Build with docker-compose using version 1.3.2

```shell
docker-compose -f docker-compose_build.yml build
```

Open the `docker-compose_build.yml` in order to change details e.g. the Version you want to build.

# Contribute

This repository uses pre-commit hooks to make sure all commits meet equal standars. To contribute install `pre-commit`
first and in the root location of the repository run:

```shell
pre-commit clean
pre-commit install
```

For every submission git will automatically check the installed hooks. To manually execute them, run:

```shell
pre-commit run --all-files
```

# Authors

* **Julian Psotta** - *Author | Initial work* - [MichaelsJP](https://github.com/MichaelsJP)

See also the list of [contributors](https://github.com/GIScience/ohsome-api-dockerized/contributors) who participated in
this project.

# License

GNU AFFERO GENERAL PUBLIC LICENSE Version 3, 19 November 2007
