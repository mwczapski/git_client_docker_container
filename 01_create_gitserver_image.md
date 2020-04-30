# 01_create_gitserver_image.sh

## Introduction

The intent of this script is to facilitate creation of a Docker Image for a private GIT Server running in as Docker Container, which uses the most recent GIT distribution, as at the time of this writing: 2.26.

Th image is based on [bitnami/minideb:jessie](https://github.com/bitnami/minideb) image, from the Docker Hub as at 20200429 or thereabouts.

Installing latest Git from sources, and pre-requisites for building Git from sources, blows the image up from about 51MB (`bitnami/minideb:jessie`) to about 778MB during the build process, and then shrinks it back to 238MB once the build is finished and build tools are removed.
The image is saved as the `gitserver:1.0.0` Docker Image and uploaded to the remote docker repository.

## Assumed host environment

- Windows 10
- Windows Subsystem for Linux (WSL)
- Docker Desktop for Windows 2.2.0.5 or higher

The script (bash) expects to run within the Windows Subsystem for Linux (WSL) Debian host and have access to docker.exe and docker-compose.exe.

## Assumed execution environment

The script is expected to br run inside the WSL Bash shell and expecs directory structure like:

`/mnt/<drive letter>/dir1/../dirN/<projectNameDir>/_commonUtils/`

The script itself, **01_create_gitserver_image.sh**, is expected to be located in the **\_commonUtils** directory and to have that directory as its working directory.

The script assumes that all projects-specific artefacts which it generates, except the docker image and the docker container, will be created in the parent directory of the **\_commonUtils** directory.

<!--
from https://plantuml.com/wbs-diagram
@startwbs
+ .
 + /mnt
  + /<drive letter>
   + /dir1
    + /...
     + /dirN
      + /giserver
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
@endwbs
-->

The following diagram depicts the fictitious directory hierarchy and actual artifacts involved. <ProjectNameDir> name is used as the name of the docker image, docker container and in a bunch of other artifacts. util diredtory containe common constant and function definitions, some of which are used in the main script.

<!-- ![Fictitious directory hierarchy and actual artifacts](./01_create_gitserver_image_directory_hierarchy.png 'Fictitious directory hierarchy and actual artifacts') -->
<img src="01_create_gitserver_image_directory_hierarchy.png" alt="Fictitious directory hierarchy and actual artifacts" width="400"/>

## "Bil of Materials"

<ol>
<li>bitnami/minideb:jessie</li>
<li>See output of <code>docker image inspect gitserver</code> once the image is built or inspect the <code>Dockerfile.gitserver</code> in the parent of the _commonUtils directory to see what actually went on. 
<li>The build script adds the following to the <code>bitnami/minideb:jessie</code> image:</li>
<ol>
    <li>tzdata</li>
    <li>net-tools</li>
    <li>iputils-ping</li>
    <li>openssh-client</li>
    <li>openssh-server</li>
    <li>nano</li>
</ol>
<li>The build script adds the following to enable git toi be built form sources, then removes them once build is done:</li>
<ol>
    <li>wget</li>
    <li>unzip</li>
    <li>build-essential</li>
    <li>libssl-dev</li>
    <li>libcurl4-openssl-dev</li>
    <li>libexpat1-dev</li>
    <li>gettext</li>
</ol>
<li>Perhaps needless to say, the build process also adds:</li>
<ol>
    <li>git</li>
</ol>
</li>
</ol>

## High-level build logic

1. Set environment variables
2. Create `docker-entrypoint.sh`
3. (Re-)Created `Dockerfile`
4. if (ImageDoes not exist) OR (`Dockerfile` changed since last time) => (Re-)Build the Docker Image using the `Dockerfile` from 3
5. if (container that uses the iage exists) => stop AND/OR remove the container
6. Create and Start the continer using appropriate Docker command
7. Give non-root user's ownership of its home directory and resources
8. Commit the image with the changes
9. Stop the image
10. Tag the image (DockerRemoteRepositoryName/ImageName:Version)
11. Push the image to the DockerRemoteRepositoryName
