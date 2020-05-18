# Git Client Docker Container

<!-- TOC -->

- [Git Client Docker Container](#git-client-docker-container)
  - [Introduction](#introduction)
  - [Assumed host environment](#assumed-host-environment)
  - [Assumed execution environment](#assumed-execution-environment)
  - [Installation](#installation)
  - [Create Git Client Docker Image: 01_create_git_client_baseline_image.sh](#create-git-client-docker-image-01_create_git_client_baseline_imagesh)
    - [Customisation](#customisation)
    - [Script invocation](#script-invocation)
    - [High-level build logic](#high-level-build-logic)
    - [Bill of Materials (of sorts)](#bill-of-materials-of-sorts)
  - [Create and Run Docker Container: 02_create_git_client_container](#create-and-run-docker-container-02_create_git_client_container)
    - [Customisation](#customisation-1)
    - [Script invocation](#script-invocation-1)
    - [High-level logic](#high-level-logic)
    - [Extras](#extras)
      - [Windows Shortcuts](#windows-shortcuts)
      - [Host-Guest-Shared "backups" directory](#host-guest-shared-backups-directory)
      - [Custom Git commands accepted by the client over SSH](#custom-git-commands-accepted-by-the-client-over-ssh)
  - [Create Remote Git Repository: 03_create_named_repo_in_private_gitserver.sh](#create-remote-git-repository-03_create_named_repo_in_private_gitserversh)
    - [Customisation](#customisation-2)
    - [Script invocation](#script-invocation-2)
    - [High-level logic](#high-level-logic-1)
  - [Delete Empty Remote Repository: 04_DeleteRemoteRepoIfEmpty](#delete-empty-remote-repository-04_deleteremoterepoifempty)
    - [Customisation](#customisation-3)
    - [Script invocation](#script-invocation-3)
    - [High-level logic](#high-level-logic-2)
  - [Add WSL public key to gitserever's authorized_keys: 05_AddWSLClientSSHKeyToGitserver_authorized_keys](#add-wsl-public-key-to-gitserevers-authorized_keys-05_addwslclientsshkeytogitserver_authorized_keys)
    - [Customisation](#customisation-4)
    - [Script invocation](#script-invocation-4)
    - [High-level logic](#high-level-logic-3)
  - [Unit Tests](#unit-tests)
  - [To-Do](#to-do)
  - [Licensing](#licensing)
  - [Note](#note)

<!-- /TOC -->

## Introduction

Scripts in this package facilitate creation of a Docker Image and a Docker Container with a Git Client that can be used with, or to test, the [private GIT Server](https://github.com/mwczapski/private_gitserver_docker_container). The image uses the git distribution from the Debian Jesse repository. The container can be used as the basis for a development environment, upon which to build a development environment with the appropriate tools like NodeJS, Java, etc..

The image is based on [bitnami/minideb:jessie](https://github.com/bitnami/minideb) image as at early May 2020.

The image is 156MB in size.

The image will be saved as the `gitclient:1.0.0` Docker Image if the `01_create_git_client_baseline_image.sh` script is run from the `..../gitclient/_commonUtils` directory and, if the user requests it, will also be uploaded to a remote docker repository, which must be defined (see later).

[Top](#Git-Client-Docker-Container)

## Assumed host environment

- Windows 10
- Docker Desktop for Windows 2.2.0.5+
- Windows Subsystem for Linux (WSL) with `/bin/bash` version at least 4.
- git installed in the WSL environment

Scripts (bash) expect to run within the Windows Subsystem for Linux (WSL) Debian host and have access to Windows' docker.exe and docker-compose.exe.

[Top](#Git-Client-Docker-Container)

## Assumed execution environment

The script expects directory structure like:

`/mnt/<drive letter>/dir1/../dirN/<projectNameDir>/_commonUtils/`

Top-level scripts, belonging to this package, are expected to be located in the **\_commonUtils** directory and to have that directory as their working directory at the time of invocation.

The scripts source a number of utility scripts, located in its `utils` subdirectory

The scripts assume that all projects-specific artifacts which are generated, except the docker image and the docker container, will be created in the parent directory of the **\_commonUtils** directory.

The following depicts the directory hierarchy and artifacts involved. The name <strong>gitclient</strong> is the `'<projectNameDir>'` in this example. The name <code>\_commonUtils</code> is the name of the directory in which the main scripts are expected to reside. The <code>utils</code> directory contains common constant and function definitions, many of which are used in the main scripts.

<!-- tree -L 3 ../../gitclient/ | sed 's/?/\+/g; s/?/-/g; s/?/\\/g; s/?/|/' > _tree.txt -->
<code>
./gitclient/</code><br><code>
+-- backups</code><br><code>
+-- _commonUtils</code><br><code>
|   +-- 01_create_git_client_baseline_image.sh</code><br><code>
|   +-- 01_create_git_client_baseline_image_tests.sh</code><br><code>
|   +-- 01_create_git_client_baseline_image_utils.sh</code><br><code>
|   +-- 02_create_git_client_container.sh</code><br><code>
|   +-- 02_create_git_client_container_tests.sh</code><br><code>
|   +-- 02_create_git_client_container_utils.sh</code><br><code>
|   +-- 03_create_named_repo_in_private_gitserver.sh</code><br><code>
|   +-- 04_DeleteRemoteRepoIfEmpty.sh</code><br><code>
|   +-- 05_AddWSLClientSSHKeyToGitserver_authorized_keys.sh</code><br><code>
|   +-- bash_test_utils</code><br><code>
|   ?   \-- bash_test_utils.sh</code><br><code>
|   +-- LICENSE</code><br><code>
|   +-- README.md</code><br><code>
|   \-- utils</code><br><code>
|       +-- __env_devcicd_net.sh</code><br><code>
|       +-- __env_gitClientConstants.sh</code><br><code>
|       +-- __env_gitserverConstants.sh</code><br><code>
|       +-- __env_GlobalConstants.sh</code><br><code>
|       +-- fn__CreateWindowsShortcut.sh</code><br><code>
|       +-- fn__DockerGeneric.sh</code><br><code>
|       +-- fn__GitserverGeneric.sh</code><br><code>
|       +-- fn__GitserverGeneric_tests.sh</code><br><code>
|       +-- fn__SSHInContainerUtils.sh</code><br><code>
|       +-- fn__SSHInContainerUtils_tests.sh</code><br><code>
|       +-- fn__UtilityGeneric.sh</code><br><code>
|       +-- fn__UtilityGeneric_tests.sh</code><br><code>
|       +-- fn__WSLPathToDOSandWSDPaths.sh</code><br><code>
|       \-- fn__WSLPathToDOSandWSDPaths_tests.sh</code><br><code>
+-- dcc exec -itu gitclient gitclient.lnk</code><br><code>
+-- dcc exec -itu root gitclient.lnk</code><br><code>
+-- dco gitclient ps.lnk</code><br><code>
+-- dco gitclient rm -s -v.lnk</code><br><code>
+-- dco gitclient stop.lnk</code><br><code>
+-- dco gitclient up --detach.lnk</code><br><code>
+-- docker-compose.yml_gitclient</code><br><code>
+-- Dockerfile.gitclient</code><br><code>
+-- gitclient</code><br><code>
|   \-- backups</code>

[Top](#Git-Client-Docker-Container)

## Installation

In a suitable location in the file system create a directory to host the package. For the first cntainer you might consider <strong>gitclient</strong>, since scripts in this package will create an image suitable for running a git client, and a container based on that image ready for use. For others, create a directory with a desired name, unpack the `_commonUtils` hierarchy to it and the script will offer it as the name.

For example (in WSL bash):

`cd <my client's directory's parent>`<br>
<code>mkdir -pv <strong>gitclient</strong></code><br>
<code>cd <strong>gitclient</strong></code>
<code>git clone https://github.com/mwczapski/git_client_docker_container.git <strong>\_commonUtils</strong></code>

[Top](#Git-Client-Docker-Container)

## Create Git Client Docker Image: 01_create_git_client_baseline_image.sh

### Customisation

Scripts `__env_devcicd_net.sh`, `__env_gitclientConstants.sh` and `fn__DockerGeneric.sh`, located in the <strong>utils</strong> subdirectory, contain main environment variables that may need to be reviewed and changed to implement customisations.

Relevant section of the `__env_devcicd_net.sh` is reproduced below. Values that can be changed are highlighted.

<hr>
<code>
__DEVCICD_NET_DC_INTERNAL=<strong>"devcicd_net"</strong></code>
<br>
<code>__DEVCICD_SUBNET_ADDRESS=<strong>"172.30.0.0/16"</strong></code>
<hr>

It is assumed that the external docker network `docker_devcicd_net` already exist. It will not be created by this script. Note that `'docker_'` is prefixed by the docker-compose to the value defined in `__DEVCICD_NET_DC_INTERNAL`. Consequently, the full name of the network will be `docker_devcicd_net` in this case. The network should be created manually, or might be created when the `01_create_gitserver_image.sh` script from the https://github.com/mwczapski/private_gitserver_docker_container packge was run to create the private git server docker container.

Variables / Constants in the `__env_gitclientConstants.sh` may need to be customised.

Script `fn__DockerGeneric.sh` contains the definition of the remote docker repository, which will have to be changed if you want to upload the image to a remote repository. If you respond with `N` to the prompt that would facilitate remote repository upload then the scrip will skip the related logic and repository name will be ignored. If you need to, change the value of:<br>

<hr>
<code>__DOCKER_REPOSITORY_HOST=<strong>"my.docker.repository.net"</strong></code>
<hr>

[Top](#Git-Client-Docker-Container)

### Script invocation

<code>cd /mnt/\<driver letter\>/dir1/../dirN/gitclient/\_commonUtils</code>

<code>
./01_create_git_client_baseline_image.sh <br>
</code>

The script will prompt you to confirm that the name of the parent directory of the `_commonUtils` directory which contains this script, and request (Y) or not (N) that the resulting image be uploaded to teh remote docker repository.

Execution of this script will result in the Dockerfile being generated and used to create the Docker Image.

[Top](#Git-Client-Docker-Container)

### High-level build logic

1. Set environment variables
2. Create `docker-entrypoint.sh`
3. Create `Dockerfile`
4. if (Image Does not exist) OR (`Dockerfile` changed since last time) => Build the Docker Image using the `Dockerfile` from 3
5. if (container that uses the image exists) => stop AND/OR remove the container
6. Create and Start the container
7. Commit continer changes to the image
8. Stop the container
9. Tag the image (ImageName:Version)
10. if (user requested push to remote docker repository) => Push the image to the defined remote docker repository

[Top](#Git-Client-Docker-Container)

### Bill of Materials (of sorts)

<ol>
<li><code>bitnami/minideb:jessie</code></li>
<li>See output of <code>docker image inspect gitclient</code> once the image is built or inspect the <code>Dockerfile.gitclient</code> in the parent of the <strong>_commonUtils</strong> directory to see what actually went on. 
<li>The build script adds the following to the <code>bitnami/minideb:jessie</code> image:</li>
<ol>
    <li><code>tzdata</code></li>
    <li><code>net-tools</code></li>
    <li><code>iputils-ping</code></li>
    <li><code>openssh-client</code></li>
    <li><code>nano</code></li>
    <li><code>less</code></li>
    <li><code>git</code></li>
</ol>
</li>
</ol>

[Top](#Git-Client-Docker-Container)

## Create and Run Docker Container: 02_create_git_client_container

### Customisation

There are no customisable properties / variables that this script uses which would not have already been customised for script `01_create_git_client_baseline_image.sh`. All scripts use the same `__env_devcicd_net.sh`, `__env_gitclientConstants.sh` and `fn__DockerGeneric.sh`, so customisation applied there carries over.

[Top](#Git-Client-Docker-Container)

### Script invocation

`cd /mnt/<driver letter>/dir1/../dirN/gitclient/\_commonUtils`<br>
`./02_create_git_client_container.sh`

The script accepts no command line arguments and expects the image produced by `01_create_git_client_baseline_image.sh` to be available.

The script will work out the parent directory name and directory hierarchy and will ask you to confirm that this is where you want to host the artifacts and name the container and container host.

The script will then prompt for container name, offering the parent directory name as the default and accepting a different name if provided.

The script will then ask whether you want to crete a remote git repository (in the gitserver configured as a private git server). If you agree to that, the script will prompt for the remote git repository name, offering the container name as the name and accepting a different name if provided.

Finally, the scrip will ask wheter you want to have a bunch of windows shortcuts created. If you respond with N, none will be created.

[Top](#Git-Client-Docker-Container)

### High-level logic

1. Work out project directory hierarchy
2. Work out project name
3. Set local environment variables
4. Confirm project directory hierarchy and project name
5. Offer container name to accept or accept different one
6. Prompt whether user wants to have have a remote git repository for this project created if it does not already exist
7. Offer default repository name and request confirmation or a new name
8. Prompt whether user wants to have Windows Shortcuts created
9. Create docker-compose.yml file
10. If (docker image does not exists) => Pull image from remote repository and abort if can't pull the image
11. If container exists but is not running => start container
12. If container does not exist => create container and start it
13. Generate SSH Key Pair for the new container
14. "Introduce" the client to the server by adding client' public ket to server's authorized_keys file
15. Add gitserver's fingerprint to client's known_hosts file and test ssh connectivity
16. (If creating remote git repo) check whether remote git repo exists and skip creation if it does
17. (If creating remote git repo) if the repo does not exists create it as `--bare` and confirm that it was created
18. If user asked for windows shortcuts => create windows shortcuts

[Top](#Git-Client-Docker-Container)

### Extras

#### Windows Shortcuts

As I run Windows Services for Linux a lot, but use Windows Explorer a fair bit, I like to have handy shortcuts that I can use to, for example, get into the container from Explorer.

The 'extras' that you might get, if you choose to have them by responding Y to the appropriate prompt, are a bunch of windows shortcuts that execute specific commands.

[Top](#Git-Client-Docker-Container)

#### Host-Guest-Shared "backups" directory

The docker-compose command that creates the docker container also creates the host directory `"backups"`, at the same level as `_commonUtils`, and mounts it as bound volume in the container.

The "backup" command, available to the user issuing the following command from a client:
<code>ssh git@gitserver backup \<reponame\></code>
will tar up the nominated remote git repository and will deposit the archive in that host directory. Just in case.

[Top](#Git-Client-Docker-Container)

#### Custom Git commands accepted by the client over SSH

<table>
<caption>Custom Git Client commands</caption><header>
<thead>
<tr>
<th>Command invocation</th>
<th>Description</th>
<tr>
</thead>
<tbody>
<tr>
<td style="vertical-align: top;">ssh git@gitserver</td>
<td style="vertical-align: top;">Will invoke a "no-login" script, present a help text and permit entry of one of the available commands</td>
</tr>
<tr>
<td style="vertical-align: top;">ssh git@gitserver help</td>
<td style="vertical-align: top;">Will display help text and exit</td>
</tr>
<tr>
<td style="vertical-align: top;">ssh git@gitserver backup &lt;git repo name&gt;</td>
<td style="vertical-align: top;">Will validate &lt;git repo name&gt;, to ensure the repo exists, and will create a timestamped zip archive of the rpository in the directory "backups" shared with the host</td>
</tr>
<!-- <tr>
<td></td>
<td></td>
</tr> -->
</tbody>
</table>

[Top](#Git-Client-Docker-Container)

## Create Remote Git Repository: 03_create_named_repo_in_private_gitserver.sh

### Customisation

There are no customisable properties / variables that this script uses which would not have already been customised for script `01_create_git_client_baseline_image.sh`. All scripts use the same `__env_devcicd_net.sh`, `__env_gitclientConstants.sh` and `fn__DockerGeneric.sh`, so customisation applied there carry over.

[Top](#Git-Client-Docker-Container)

### Script invocation

`cd /mnt/<driver letter>/dir1/../dirN/gitclient/\_commonUtils`

`03_create_named_repo_in_private_gitserver.sh [<Name of New Repository>] [<Path To id_rsa.pub>]`

The script expects the container, produced by `02_create_git_client_container.sh` to be running.

The script accepts two optional arguments.

<table>
<caption>Script Arguments</caption><header>
<thead>
<tr>
<th>Argument</th>
<th>Description</th>
<th>Default</th>
<tr>
</thead>
<tbody>
<tr>
<td style="vertical-align: top;">&lt;Name of New Repository&gt;</td>
<td>Optional.<br>The name of the new remote repository.<br>If the repository already exists the script will abort with a note to that effect.<br>
If the repository does not exist it will be created as a "bare" repository.
</td>
<td style="vertical-align: top;">gittest</td>
</tr>
<tr>
<td style="vertical-align: top;">&lt;Path To id_rsa.pub&gt;</td>
<td>Optional.<br>The script needs to connect to the remote repository using ssh. To accomplish this the git client needs to "know" the client. Providing the path to the client's id_rsa.pub will enable the script to add the public key to the client's authorised_keys store and then add the repository. As a side-effect the client will be able to invoke custom commands the git client offers, for example <code>ssh git@gitserver list</code> or <code>ssh git@localhost -p 50022 list</code> if using WSL in windows on which the docker is installed.</td>
<td style="vertical-align: top;">~/.ssh/id_rsa.pub</td>
</tr>
</tbody>
</table>

[Top](#Git-Client-Docker-Container)

### High-level logic

1. Get repository name and location of id_rsa.pub from the command line, or substitiute defaults.
2. Validate repository name and existence and content of the file => abort if invalid
3. Authorise client to ssh into the client by adding the `id_rsa.pub` to client's `authorized_hosts` store
4. Determine whether repository already exists and abort if it does or the existence cannot be established
5. Create the repository (as `--bare`) => abort if failed to create the repository

[Top](#Git-Client-Docker-Container)

## Delete Empty Remote Repository: 04_DeleteRemoteRepoIfEmpty

### Customisation

There are no customisable properties / variables that this script uses which would not have already been customised for script `01_create_git_client_baseline_image.sh`. All scripts use the same `__env_devcicd_net.sh`, `__env_gitclientConstants.sh` and `fn__DockerGeneric.sh`, so customisation applied there carry over.

[Top](#Git-Client-Docker-Container)

### Script invocation

cd /mnt/\<driver letter\>/dir1/../dirN/gitclient/\_commonUtils

`04_DeleteRemoteRepoIfEmpty [<Name of Existing Empty Repository>]`

The script expects the container, produced by `02_create_git_client_container.sh` to be running.

The script accepts one optional argument.

<table>
<caption>Script Arguments</caption><header>
<thead>
<tr>
<th>Argument</th>
<th>Description</th>
<th>Default</th>
<tr>
</thead>
<tbody>
<tr>
<td style="vertical-align: top;">&lt;Name of Existing Empty Repository&gt;</td>
<td>Optional.<br>The name of the remote repository to delete.<br>
If the repository does not exists the script will abort with a note to that effect.<br>
If the repository already exists but is not empty the script will abort with a note to that effect.<br>
If the repository exist and is empty (<code>git count-objects</code> returns 0 objects).
</td>
<td style="vertical-align: top;">gittest</td>
</tr>
</tbody>
</table>

[Top](#Git-Client-Docker-Container)

### High-level logic

1. Get repository name from the command line, or substitiute default.
2. Validate repository name => abort if invalid
3. Verify that client running the script is authorised to ssh into the client
4. Determine whether repository already exists and abort if it does not or the existence cannot be established
5. Determine whether repository is empty and abort if it is not empty or the command triggered an error
6. Delete the repository (exisiting and empty) => abort if failed to delete the repository
7. Verify that repository was deleted

[Top](#Git-Client-Docker-Container)

## Add WSL public key to gitserever's authorized_keys: 05_AddWSLClientSSHKeyToGitserver_authorized_keys

### Customisation

There are no customisable properties / variables that this script uses which would not have already been customised for script `01_create_git_client_baseline_image.sh`. All scripts use the same `__env_devcicd_net.sh`, `__env_gitclientConstants.sh` and `fn__DockerGeneric.sh`, so customisation applied there carry over.

[Top](#Git-Client-Docker-Container)

### Script invocation

`cd /mnt/\<driver letter\>/dir1/../dirN/gitclient/\_commonUtils`

`./05_AddWSLClientSSHKeyToGitserver_authorized_keys.sh`

The script expects the container, produced by `02_create_git_client_container.sh` to be running.

The script accepts no arguments and expects the `~/.ssh/id_rsa.pub` to exist.

[Top](#Git-Client-Docker-Container)

### High-level logic

1. Get content of `~/.ssh/id_rsa.pub`
2. Add it to the giserver's authorized_hosts file

[Top](#Git-Client-Docker-Container)

## Unit Tests

Unit tests are provided for some modules alongside the module sources to which they pertain.

This is still work in progress/.

[Top](#Git-Client-Docker-Container)

## To-Do

<ol>
<li>Better customisation experience (externally-defined customisation variables AND/OR configuration script)</li>
<li>Add automatic repository backup on push functionality</li>
<li>Add recover repository from selected backup functionality</li>
</ol>

[Top](#Git-Client-Docker-Container)

## Licensing

The MIT License (MIT)

Copyright © 2020 Michael Czapski

Rights to Docker (and related), Git (and related), Debian, its pakages and libraries, and 3rd party packages and libraries, belong to their respective owners.

[Top](#Git-Client-Docker-Container)

## Note

[Top](#Git-Client-Docker-Container)

If you would like me to consider working for you, working with you on an interesting project, or engaging in specific projects for you, feel free to contact me.

[Top](#Git-Client-Docker-Container)

2020/05 MCz
