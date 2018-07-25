# RGalaxy

Creating Galaxy tools from R scripts
================
17/05/2018
Update 25/07/2018

Lodewic Twillert & Robin van Stokkum

CreateGalaxyTools
=================

This repository contains an R package called `MyGalaxyTools` that is used to collect R scripts, rewritten as functions in order to generate Galaxy tools.
This readme is build up as follows. First, it is explained how to get a local instance of Galaxy with Planemo running using Docker to test-run and create the Galaxy tools using this R package. Second, it is explained how to obtain a copy of this repository. 
Third, an example is shown of the creation of a simple Galaxy tool based on a R script. First by rewriting the R script as commmand-line runnable function and then wrapping the code in XML to create the actual tool. 


# Planning for June:
```bash
TO_DO list for dev team
(i)   create two separate DVs: a galaxy and a R-for-galaxy page
(ii)  further automate the R functio to Galaxy tool
(iii) improve writing both in substance and structure
(iv)  create usable tool based on subtyping tool Tim (create usecase of the platform)
(v)   create comprehensive draft for scripting requirements for using the Galaxy/R platform
(vi)  extend the workflow to enable Python code as well 

```

Installing docker to run Planemo and Galaxy
===========================================

Planemo is a tool that should be used to develop Galaxy tools. Galaxy tools are defined as .XML files, and Planemo helps us to,

-   Generate a skeleton Galaxy tool as a template .xml file
-   Initialize a galaxy tool with a name, requirements, categories, etc.
-   Set tool dependencies
-   Use the `lint` command to check .xml files for validity
-   Use the `test` command to test our tools before deploying to Galaxy
-   Publish tools to the test toolshed, [testtoolshed.g2.bx.psu.edu/](https://testtoolshed.g2.bx.psu.edu/)

Galaxy is a platform to publish analysis tools for reproducible and data-intensive research, specifically facilitating bioinformatics. We can install tools to Galaxy from the testtoolshed while we are still learning to develop these Galaxy tools directly from R 
scripts.

We can run Planemo and Galaxy using Docker on Windows. We use a dockerfile for Galaxy, found on [Docker Hub](https://hub.docker.com/r/bgruening/galaxy-stable/). Thanks to [Björn Grüning](https://github.com/bgruening) we can use a well-maintained docker image to 
run Galaxy without having to install Galaxy locally on Linux.

Install Docker for Windows
--------------------------

[Follow these instructions to install Docker for Windows](https://docs.docker.com/docker-for-windows/install/).

Since Galaxy needs Linux to operate, we install Docker- so we can keep using Windows for easy and accessible evelopment of Galaxy tools from R scripts.

This guide has an important limitation, namely that hyper-v needs additional settings to work properly, see the following link: <https://illuminati.services/2017/06/02/docker-on-windows-mobylinuxvm-failed-to-realize-fixed/>

After you installed Docker, see if it works by opening up Powershell and using

``` bash
foo@bar: ~$ docker images

REPOSITORY                 TAG                 IMAGE ID            CREATED             SIZE
bgruening/galaxy-stable    latest              b67fc4084259        11 days ago         3.04GB
planemo/interactive        latest              e0b01f963fb1        3 months ago        4.29GB
docker4w/nsenter-dockerd   latest              cae870735e91        6 months ago        187kB
bgruening/planemo          latest              cff707c27ab5        11 months ago       1.81GB
```

Although you'll likely find that you have no images yet.

To get the `bruening/galaxy-stable` image we find the instructions on Docker Hub. Go to, <https://hub.docker.com/r/bgruening/galaxy-stable/#Usage> to find detailed instructions and options. But if you, like us, just need this to work for now you can follow along 
below.

Setting up Galaxy:
------------------

open powershell add copy paste:

`docker run -d -p 8080:80 -p 8021:21 -p 8022:22 bgruening/galaxy-stable`

This will start up a docker image for you with the galaxy image pulled from <https://hub.docker.com/r/bgruening/galaxy-stable/#Usage> . It opens up the port localhost/8080 , 8021 and 8022. Read more about these ports and what they are used for using the linx 
above.

The `localhost` on Windows is set by default to `127.0.0.1`, to access port 8080 containing the Galaxy instance, open a browser and surf to,

<http://127.0.0.1:8080/>

If everything you works you should find the hosted local Galaxy instance here.

![](images/GalaxyLocalHost.png)

If it didn't work, make sure the docker images started by running

``` bash
docker ps
```

Powershell, it should then list your running docker process.

Go to, <https://hub.docker.com/r/bgruening/galaxy-stable/#Usage> if you need to need more information to get Galaxy running using Docker.

Map local folder containing tool to add to galaxy container:
------------------------------------------------------------

Now, find the name of your docker container by checking the output of `docker ps`. For example,

``` bash
$ docker ps

CONTAINER ID        IMAGE                     COMMAND              CREATED             STATUS              PORTS                                                                                           NAMES
344375995c84        bgruening/galaxy-stable   "/usr/bin/startup"   About an hour ago   Up About an hour    443/tcp, 8800/tcp, 9002/tcp, 0.0.0.0:8021->21/tcp, 0.0.0.0:8022->22/tcp, 0.0.0.0:8080->80/tcp   sharp_mirzakhani


$ docker kill sharp_mirzakhani
```

Then we start up a new images, this time **mapping a local folder containing our tools to a folder within the docker image**. For this we use the `docker -v` argument, take a look at `docker --help` to learn more about the available options. Although, we do not 
deviate much from the most basic options to make this as *simple* as possible.

Open up your powershell when you have no more docker processes running and run,

``` bash
PS C:\Users\twillerthtlv> docker run -d -p 8080:80 -p 8021:21 -p 8022:22 -v c:/users/twillerthtlv/GitLab/Galaxy/inst/gal
axy/tools/mytool:/local_tools bgruening/galaxy-stable
```

Your local tools folder is now mapped to a folder within the docker image, so whenever we change something in our Windows folder this change will also happen within the docker Image. And vice versa!

Now, how do we use these local tools from within the docker image so that we can test these tools?

#### Issue with relative path to folder

I'm pretty sure you can use a relative folder containing your local Galaxy tools, but I get the following result,

``` bash
PS C:\Users\twillerthtlv> docker run -d -p 8080:80 -p 8021:21 -p 8022:22 -v ./GitLab/Galaxy/inst/galaxy/tools/mytool:/lo
cal_tools bgruening/galaxy-stable
C:\Program Files\Docker\Docker\Resources\bin\docker.exe: Error response from daemon: create GitLab/Galaxy/inst/galaxy/tools/mytool: "GitLab/Galaxy/inst/galaxy/tools/mytool" includes invalid characters for a local volume name, only "[a-zA-Z0-9][a-zA-Z0-9_.-]" are 
allowed. If you intended to pass a host directory, use absolute path.
See 'C:\Program Files\Docker\Docker\Resources\bin\docker.exe run --help'.
```

### Getting into the Galaxy Docker image

(Remember you can use `docker ps` to find the names of running galaxy instances.)

Now you can use `bash` to *get into* the docker image, containing a running Galaxy instance. We use `docker exec` with option `-it` to get an *interactive* environment pointed at the galaxy instance. Then from there we run `bash` to open up bash, the Unix command 
line used in Linux and Mac OS.

``` bash
PS C:\Users\twillerthtlv> docker exec -it sharp_mirzakhani bash
root@344375995c84:/galaxy-central#
```

See how you changed the folder from `PS ...` (PowerShell) to `root@...` (a unix directory). This means you *entered* the docker image! Now, note that this is a completely separate operating system from your own Windows system. The only things that are shared are 
the ports that we opened up ()

Now, while you are *in* this docker image you should get used to the Linux command line. Most basically- use `ls` to list files, `cd` to change directories.

### Finding your local folder in Docker

Now we are in /home/galaxy-central, the starting folder of this galaxy instance. We mapped a local folder to `/local_tools/`, a folder containing some local code or functions and tools.

(We did this with `docker run -d -p 8080:80 -p 8021:21 -p 8022:22 -v c:/users/twillerthtlv/GitLab/Galaxy/inst/galaxy/tools/mytool:/local_tools bgruening/galaxy-stable`)

To go to this folder,

-   use `cd ..` to go *up* one folder from /galaxy-central.
-   then use `ls` to list the directory you are in
-   notice that this is where the `/local_tools` folder is located and go to it using `cd local_tools`
-   list the directory and confirm that is the same as your local Windows folder

``` bash
root@344375995c84:/galaxy-central# cd ..
root@344375995c84:/# ls
ansible  cvmfs  export          home         media  root        srv        usr
bin      data   galaxy          lib          mnt    run         sys        var
boot     dev    galaxy-central  lib64        opt    sbin        tmp
core     etc    galaxy_venv     local_tools  proc   shed_tools  tool_deps
root@344375995c84:/# cd local_tools/
root@344375995c84:/local_tools# ls
CreateDESeqData.R    generate_runnable.R  tool_test_output.html
CreateDESeqData.xml  test-data            tool_test_output.json
root@344375995c84:/local_tools#
```

Install Planemo
---------------

Please notice that we are not expects with Docker and as such have not made our own DockerFile. Although we have learned a lot about them partly from learning how [Aurora Galaxy Tools](https://github.com/statonlab/aurora-galaxy-tools) are made. This repository 
includes a dockerfile at <https://github.com/statonlab/aurora-galaxy-tools/tree/master/docker-aurora-rnaseq> . Following the small number of steps in this dockerfile very closely can be a great way to learn how to install our own tools to a custom Galaxy docker 
image hosted on a server. Since this DockerFile does not contain many steps we are confident that we can adjust this image to our own, very similar, needs.

We still need Planemo to install and build tools, so from within the Galaxy docker image, we use `pip` to install new packages. Pip is a package manager used for python packages. We can use pip from the command line to install python packages, like Planemo and 
Galaxy!

``` bash
pip install --upgrade pip
pip install planemo         
```





Creating a tool
===============

We create tools partly using the `RGalaxy` package, which only works with functions that are part of an existing library. Therefore the functions in this package don't have a single purpose but are simply collected so they can be documented using the `roxygen2` 
package, and the documentation can be then be used to create Galaxy tools.

``` r
# Set your working directory to this repository locally
# For now, all the output is saved to this package
#   TODO: Create tools in any other folder besides this package ... 
library(devtools)
install()
```

Follow instructions below to get this repository locally from GitLab.

For example, find the script `/R/CreateDDS.R`. It contains a function, `CreateDESeqData()`. This function is installed with this package and can be used to see how a function is made into a Galaxy Tool.

You just run,

``` r
library(MyGalaxyTools)
# setwd("GALAXY REPOSITORY")

### THIS WON'T WORK
###   func is parsed to a character as "func" and not "CreateDESeqData" internally
# func <- CreateDESeqData
# MakeGalaxyTool(func)
```

``` r
# Pass the direct function you want to create a tool from directly to MakeGalaxyTool()
MakeGalaxyTool(CreateDESeqData)

### Example output
# Trying to create functional tests...
# Test directory 'inst/functionalTests/CreateDESeqData' already exists. Overwriting results!
#   $countdata
# [1] "C:/Users/username/Documents/R/R-3.4.3/library/MyGalaxyTools/functionalTests/CreateDESeqData/countdata"
# 
# $coldata
# [1] "C:/Users/username/Documents/R/R-3.4.3/library/MyGalaxyTools/functionalTests/CreateDESeqData/coldata"
# 
# $outputDds
# [1] "outputDds"
# 
```

Installation and documentation
==============================

Make sure you have Git installed and configured locally first. Pull the repository locally and install from there.

### Pull repository

You could `git clone` your repository, although this has not worked for me with GitLab. I run into authentication errors and rather do it by initializing a new local repository and pulling data from GitLab.

Assuming you're using Git bash on Windows, open Git bash and create a PhenoDb folder wherever you want to initialize the git repository.

For example make a folder `C:\Users\yourusername\...\GitLab\Galaxy`.

``` r
cd existing_folder
git init
git remote add origin https://:@gitlab-dv.tno.nl:443/twillerthtlv/Galaxy.git
git pull
```

### Install from R

This directory contains the package `MyGalaxyTools`, which you can install in R. Sorry for the confusing naming, this repository will be renamed:)

Set your working directory to your local Galaxy repository folder and run the following.

``` r
library(devtools)
install()
```

You can edit the functions in the /R folder, or any other folder, and re-install the package whenever you do to test updates.

Documentation
-------------

Documentation can be found by opening the `docs/index.html` file in your browser. This documentation site will hopefully soon be hosted on GitLab with GitLab pages.

You'll find documented functions using roxygen-style comments. If you want to contribute then make sure to document functions similarly. Learn more in this [roxygen2 vignette](https://cran.r-project.org/web/packages/roxygen2/vignettes/rd.html).

You can use the [pkgdown](https://github.com/r-lib/pkgdown) package from our boy Hadley to create documentation websites easily. The package was also recently accepted to CRAN and you can install it like any other package.



XML wrapper
-----------

To use your own R scripts within the Galaxy environment, they need to be enclosed by a XML wrapper. For this, we use the RGalaxy R function. A drawback of this function is the need to create a package with the proper documentation. This documentation is what 
RGalaxy uses to create the appropriate XML annotations.

Another requirement is that the R function is runnable from the command line. For this latter purpose, "generate\_runnable.R" can be found on the GitLab DV.

