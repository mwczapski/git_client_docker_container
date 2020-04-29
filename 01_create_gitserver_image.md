# 01_create_gitserver_image.sh

## Introduction

The intent of this script is to facilitate creation of a Docker Image for a GIT Server which uses the most recent GIT distribution.

Th image is based on bitnami/minideb:jessie image, from the Docker Hub as at 20200429 or thereabouts.

Installing lates NodeJS from sources, and pre-requisites for building Git from sources, blows the image up from about 51MB (bitnami/minideb:jessie) to about 777MG (gitserver:1.0.0)
