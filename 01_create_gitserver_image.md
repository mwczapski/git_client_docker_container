# 01_create_gitserver_image.sh

## Introduction

The intent of this script is to facilitate creation of a Docker Image for a GIT Server which uses the most recent GIT distribution.

Th image is based on [bitnami/minideb:jessie](https://github.com/bitnami/minideb) image, from the Docker Hub as at 20200429 or thereabouts.

Installing latest NodeJS from sources, and pre-requisites for building Git from sources, blows the image up from about 51MB (bitnami/minideb:jessie) to about 777MG (gitserver:1.0.0)

**Assumed host environment**:

- Windows 10
- Windows Subsystem for Linux (WSL)
- Docker Desktop for Windows 2.2.0.5 or higher

The script (bash) expects to run within the Windows Subsystem for Linux (WSL) Debian host and have access to docker.exe and docker-compose.exe.

The script is expected to br run inside the WSL Bash shell and expecs directory structure like:

`/mnt/<drive letter>/dir1/../dirN/<projectNameDir>/_commonUtils/`

The script itself, **01_create_gitserver_image.sh**, is expected to be located in the **\_commonUtils** directory and to have that directory as its working directory.

The script assumes that all projects-specific artefacts which it generates, expcept the docker image and the docker container, will be created in the parent directory of the **\_commonUtils** directory.

<!--
from https://plantuml.com/wbs-diagram
@startwbs
+ .
 + /mnt
  + /<drive letter>
   + /dir1
    + /...
     + /dirN
      + /<ProjectNameDir>
       + /_commonUtils
        + /01_create_gitserver_image.sh
        + /utils
         + /__env_devcicd_net.sh
         + /__env_gitserverConstants.sh
         + /__env_YesNoSuccessFailureContants.sh
         + /fn__ConfirmYN.sh
         + /fn__CreateWindowsShortcut.sh
         + /fn__DockerGeneric.sh
         + /fn__FileSameButForDate.sh
         + /fn__WSLPathToDOSandWSDPaths.sh
@endwbs -->

The following diagram depicts the fictitious directory hierarchy and actual artifacts involved. <ProjectNameDir> name is used as the name of the docker image, docker container and in a bunch of other artifacts. util diredtory containe common constant and function definitions, some of which are used in the main script.

![Pfictitious directory hierarchy and actual artifacts](./01_create_gitserver_image_directory_hierarchy.png 'fictitious directory hierarchy and actual artifacts')

## High-level build logic

1.
