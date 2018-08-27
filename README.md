# RGalaxify

Creating Galaxy tools from R scripts
================
17/05/2018
Update 25/07/2018

Lodewic Twillert & Robin van Stokkum

CreateGalaxyTools
=================

Galaxy is a platform to publish analysis tools for reproducible and data-intensive research, specifically facilitating bioinformatics. This repository contains an R package called `RGalaxify` that is used to collect R scripts, rewritten as functions in order to generate Galaxy tools. This package is heavily borrowing from the [RGalaxy](https://bioconductor.org/packages/release/bioc/html/RGalaxy.html). 

This readme is build up as follows. First, an example is shown of the creation of a simple Galaxy XLM tool based on a R script. First by rewriting the R script as commmand-line runnable function and then wrapping the code in XML to create the actual tool. Second, it is explained how to get a local instance of Galaxy with Planemo running using Docker to test-run and create the Galaxy tools using this R package. 

# Planning:
```bash
TO_DO list for dev team
- [ ] create two separate DVs: a galaxy and a R-for-galaxy page (first get them together!)
- [ ] further automate the R function to Galaxy tool
- [ ] improve writing both in substance and structure
- [ ] create usable tool based on subtyping tool Tim (create usecase of the platform)
- [ ] create comprehensive draft for scripting requirements for using the Galaxy/R platform
- [ ] extend the workflow to enable Python code as well 

```

1) Creating an XML tool from R code
===================================

We create tools partly using this `RGalaxy` package, which only works with functions that are part of an existing library. Therefore the functions in this package don't have a single purpose but are simply collected so they can be documented using the `roxygen2` 
package, and the documentation can be then be used to create Galaxy tools. You can download the zip version by pressing 'Clone' above or use Git bash and pull.

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


RGalaxify
=========

This repository contains an R package called `RGalaxify` that is used to generate Galaxy tools from R functions directly. Most of the credit should go to the creators of the [RGalaxy](https://bioconductor.org/packages/release/bioc/html/RGalaxy.html) package, since we built on their work and edited it fit our needs.

Installation
------------

Pull the repository locally and install from there. (You'll need to have your Git setup configured correctly first to connect in the first place.)

### Pull repository

You could `git clone` your repository, although this has not worked for me with GitLab. I run into authentication errors and rather do it by initializing a new local repository and pulling data from GitLab.

Assuming you're using Git bash on Windows, open Git bash and create a RGalaxify folder wherever you want to initialize the git repository.

I recommend making a folder `C:\Users\yourusername\...\RGalaxify` for this package.

``` r
cd existing_folder
git init
git remote add origin https://:@gitlab-dv.tno.nl:443/DataScience-MSB/GalaxyProjects/RGalaxify.git
git pull
```

Now you can look at `docs/index.html` locally to find function documentation and an example vignette going for the use of this package.

What does it do?
================

What it achieves
----------------


This vignette is the first attempt to generate a Galaxy tool from an arbitrary
R script. The script is expected to include functions with roxygen-style 
documentation.

Also, these R functions should be lightly edited so that their expected 
parameters can be parsed by the functions from the [RGalaxy](https://bioconductor.org/packages/release/bioc/html/RGalaxy.html)
package.

The biggest shortcoming of the RGalaxy package in my opinion is that the generated
tool script relies on the used R function to be in a publically available package.
The Galaxy tools will not include the right requirements tags needed to publish 
the generated Galaxy tools to any Galaxy instance.

Our approach will use a lot of the functionality of the RGalaxy package, but 
rewritten in a way that we use arbitrary custom R functions. To see an example
workflow of how to generate tools using RGalaxy, see 
[this RGalaxy vignette](https://bioconductor.org/packages/release/bioc/vignettes/RGalaxy/inst/doc/RGalaxy-vignette.html). However, the vignette is not very easy to follow but
it shows some examples and descriptions that we won't go over in this document.

# Creating a basic galaxy tool

Your R scripts need to be self-contained function definitions, for now.
Later this should be extended to include tools that depend on other local functions
that may be loaded with a simple `source()` command.

Another note is that this assumes the original R function is command line runnable. There is function included in this package ("generate_runnable.R") which assist you in doing so. 

The source R scripts can be given as a character vector of filenames, relative
to the current working directory.

## AddTwoNumbersWithTest

In this case we use the `addTwoNumbersWithTest.R`. This file includes one very
simple function defintion. All this script included is a function to sum two numbers and write the output to
a file. In Galaxy we always expect the output to be a file, or collection of files.
You can output R variables in .rds format, which may force you to change some
other functions to take a file input rather than just an R variable.

Notice the following about the function definition below,

  * [roxygen2](http://kbroman.org/pkg_primer/pages/docs.html)-style comments for function documentation
  * The input parameters are [Galaxy Parameter Classes](https://rdrr.io/bioc/RGalaxy/man/GalaxyClasses.html)
  * The output is written to a .txt file
  
The documentation is used to create a help section to display in Galaxy.

The input parameters are defined by Galaxy Parameter Classes, following the 
methods in the RGalaxy package. This allows galaxy to understand the expected
parameters and show them nicely in the Galaxy UI.

```{r}
# The addTwoNumbersTest.R file

#' Add to numbers
#' 
#' A test function to use as an example to create a galaxy tool.
#' It takes two numeric values and returns the sum to a .txt file.
#'
#' @param number1 First numeric value to sum
#' @param number2 Second numeric value to sum
#' @param sum Output file
#' 
#' @details
#' Both arguments are required and contain test values to
#' automatically generate tool tests with.
#' These tests are included in the output .xml tool definition, and
#' can be tested using Planemo's test command.
#'
#' @return The sum of two values
#' @export
#'
#' @examples
# outfile <- tempfile(pattern = "sum")
# addTwoNumbersWithTest(5, 5, sum = outfile)
# readLines(outfile)
#' 
addTwoNumbersWithTest <- 
  function(
    number1=GalaxyNumericParam(required=TRUE, testValues=5L),
    number2=GalaxyNumericParam(required=TRUE, testValues=5L),
    sum=GalaxyOutput("sum", "txt"))
  {
    cat(paste0(number1 + number2, "\n"), file=sum)
  }
```
You can still use this function straight in R, which is handy for testing but
in many cases you could just make it a habit of writing function definitions like
this right away!

```{r}
# Example of function output using normal R variables
outfile <- tempfile()
addTwoNumbersWithTest(number1 = 5, number2 = 5, sum = outfile)
readLines(outfile)
```

## Setting up tool output

The output will be written to a tool directory, `toolDir`.
You may have only 1 tool directory but still have different groups of tools, 
set by `toolGroup`. 

```{r Set parameters}
toolScripts <- c("addTwoNumbersWithTest.R")
toolDir <- "tools"
toolGroup <- "mytool"
toolPath <- file.path(toolDir, toolGroup)

# Create tool directory if it does not yet exist
if (!dir.exists(toolPath)) {
  warning(sprintf("Tool directory '%s' does not exist and will be created",
                  toolPath))
  dir.create(toolPath, recursive = T)
}
```

## Creating temporary package

Since our functions to transform into galaxy tools are not part of a package 
we can't just use `roxygen2::roxygenise()`. For us to create documentation the 
scripts need to be part of a package. So we create a temporary package for our functions.

```{r}
require(devtools)

# Create temporary package directory
tempPackageDir <- file.path(tempdir(), "TempGalaxyToolPackage")
# Initialize R package file structure
if (dir.exists(tempPackageDir)) unlink(tempPackageDir, recursive = T)
devtools::create(path = tempPackageDir,
                 rstudio = F)

# Copy scripts to package R directory
file.copy(from = toolScripts, to = file.path(tempPackageDir, "R"))
# Document R functions in the R directory
devtools::document(tempPackageDir)

# File directory example
list.files(tempPackageDir, recursive = T)
```

For every **documented** function we can create a galaxy tool.
Every function gets its own .Rd file in the `man/` directory. Using this
we can list the functions to galaxify.

```{r List functions to galaxify}
# List all functions to galaxify
#   Based on the criteria that they need to be documented
functionDocs <- list.files(file.path(tempPackageDir, "man"))
# Only 1 function in this case, otherwise we should create a loop.
funcName <- sapply(functionDocs, gsub, pattern = ".Rd", replacement = "")
cat(funcName,
    sep = "\n")
```

## Prepare documentation and function definition

Firstly we need to gather the documentation for our new tool/function.
This can be found in the `man/` directory of our temporary package. 

Here we print the contents of the .Rd documentation file created when we ran the
`devtools::document()` function. These files get created by the `roxygen2`package,
look up the documentation if you wish to learn more about the options and 
formatting.

```{r Get documentation for addTwoNumbersWithTest}
rd <- parse_Rd(file.path(tempPackageDir, "man", functionDocs))
print(rd)
```


```{r Get definition of addTwoNumbersWithTest}
fullToolDir <- toolPath
scriptFileName <-  toolScripts
source(scriptFileName)
functionToGalaxify <- get(funcName) # Get the function to galaxify
funcInfo <- list()
print(formals(functionToGalaxify))
```

# Further work

This is still a work in progress, below are the next steps to rewrite.
All this code is taken from the RGalaxy package, or specifically from my
edited Github mirror of it [found here](https://github.com/Lodewic/RGalaxy).

Look for the `R/` repository and you'll find the `R/galaxy.R` script that contains
most of the functions we need. Although many of the functions we DONT need, 
so we will work on rewriting the required functions.

```{r work in progress, eval = FALSE}
if  (  length(names(formals(functionToGalaxify)))   > length(formals(functionToGalaxify)) )
  gstop("All arguments to Galaxy must be named.")

for (param in names(formals(functionToGalaxify)))
  funcInfo[[param]] <- getFuncInfo(functionToGalaxify, param)

# print(funcInfo)
if (!isTestable(funcInfo, funcName, package, functionalTestDirectory)) 
  gwarning("Not enough information to create a functional test.")
  
if (!suppressWarnings(any(lapply(funcInfo,
  function(x)x$type=="GalaxyOutput"))))
{
  gstop(paste("You must supply at least one GalaxyOutput",
      "object."))
}

createScriptFile(scriptFileName, functionToGalaxify, funcName, funcInfo,
  package, RserveConnection)

### Create tool from scripts and documentation




# file.copy(system.file("galaxy", "tool_conf.xml", package="RGalaxy"),
#           file.path(galaxyHome, "tool_conf.xml"), overwrite=FALSE)

# functionalTestDirectory <- "inst/functionalTests"
# funcTestDirectory <- file.path(functionalTestDirectory, funcName)
# message("Trying to create functional tests...")
# funTest <- CreateFunctionalTest(funcName, functionalTestDirectory)
# 
# mywd <- getwd()

# Make temporary package with R scripts included
# These scripts can then include Roxygen2-style comments as is used for package
# documentation.
#   RGalaxy requires your scripts to be in a package, most importantly to be
#   able to use the generated documentation files (.rd format). 


message("Building galaxy tool...")
galaxy(funcName,
       galaxyConfig=GalaxyConfig(galaxyHome, toolDir,
                                 "Local tools", toolDir),
       RserveConnection=NULL,
       functionalTestDirectory = functionalTestDirectory)
```

Examples
--------

For more examples to get started, look at the `docs/index.html` file or find the vignette in `vignettes/`.

RGalaxy difference
------------------

RGalaxy also creates Galaxy tools from R scripts, but the output tools are not immediately fit to publish and host on any Galaxy instance. For one,

-   RGalaxy expects functions to be part of a publically available package
-   RGalaxy uses a local Galaxy instance

This works well because all you'd have to do is load the function from an existing package and write a wrapper function that loads the library and then calls the relevant function. However, we often want to write our own tools and functions that we can publish as a Galaxy tool.

In our case,

-   RGalaxify uses any custom function to generate a valid Galaxy tool
-   You can `lint` and `test` the output with [Planemo](http://planemo.readthedocs.io/en/latest/writing.html)

This means we will have to deal with dependencies differently. Also, we do not need a lot of the functionality that RGalaxy offers, such as using `RServe` to serve computationally heavy tasks to a separate R instance.

[lets see if Conda can help here]


Now that we have a XML wrapped R function, lets setup Galaxy and Planemo to test it. 


Installing docker to run Planemo and Galaxy
===========================================

Planemo is a tool that should be used to develop Galaxy tools. Galaxy tools are defined as .XML files, and Planemo helps us to,

-   Generate a skeleton Galaxy tool as a template .xml file
-   Initialize a galaxy tool with a name, requirements, categories, etc.
-   Set tool dependencies
-   Use the `lint` command to check .xml files for validity
-   Use the `test` command to test our tools before deploying to Galaxy
-   Publish tools to the test toolshed, [testtoolshed.g2.bx.psu.edu/](https://testtoolshed.g2.bx.psu.edu/)

 We can install tools to Galaxy from the testtoolshed while we are still learning to develop these Galaxy tools directly from R 
scripts.

We can run Planemo and Galaxy using Docker on Windows. We use a dockerfile for Galaxy, found on [Docker Hub](https://hub.docker.com/r/bgruening/galaxy-stable/). Thanks to [Björn Grüning](https://github.com/bgruening) we can use a well-maintained docker image to run Galaxy without having to install Galaxy locally on Linux.

Install Docker for Windows
--------------------------

[Follow these instructions to install Docker for Windows](https://docs.docker.com/docker-for-windows/install/).

Since Galaxy needs Linux to operate, we install Docker- so we can keep using Windows for easy and accessible evelopment of Galaxy tools from R scripts.

This guide has an important limitation, namely that hyper-v needs additional settings to work properly, see the following link: <https://illuminati.services/2017/06/02/docker-on-windows-mobylinuxvm-failed-to-realize-fixed/>

After you installed Docker, have it running in the background (icon in the toolbar) see if it works by opening up Powershell and using

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

This will start up a docker image for you with the galaxy image pulled from <https://hub.docker.com/r/bgruening/galaxy-stable/#Usage> . It opens up the port localhost/8080 , 8021 and 8022. Read more about these ports and what they are used for using the link 
above. The pulling will take a few minutes due to the image size. 

The `localhost` on Windows is set by default to `127.0.0.1`, to access port 8080 containing the Galaxy instance, open a browser and surf to,

<http://127.0.0.1:8080/>

If everything you works you should find the hosted local Galaxy instance here.

![](images/GalaxyLocalHost.png)

If it didn't work, make sure the docker images started by running

``` bash
docker ps
```

 in Powershell. It should then list your running docker process like this:

``` bash 
CONTAINER ID        IMAGE                     COMMAND              CREATED             STATUS              PORTS                                                                                           NAMES
ae2d57ce7733        bgruening/galaxy-stable   "/usr/bin/startup"   22 seconds ago      Up 20 seconds       443/tcp, 8800/tcp, 9002/tcp, 0.0.0.0:8021->21/tcp, 0.0.0.0:8022->22/tcp, 0.0.0.0:8080->80/tcp   jolly_lumiere
```

Go to, <https://hub.docker.com/r/bgruening/galaxy-stable/#Usage> if you need to need more information to get Galaxy running using Docker.

Map local folder containing tool to add to Galaxy container:
------------------------------------------------------------

In order to add a tool to Galaxy and test it locally using Planemo, we need to map a local folder, which will contain the tool, to the Galaxy image. Now, find the name of your docker container by checking the output of `docker ps`. We use the image from Gruening, as showed above, which results in

``` bash
$ docker ps

CONTAINER ID        IMAGE                     COMMAND              CREATED             STATUS              PORTS                                                                                           NAMES
344375995c84        bgruening/galaxy-stable   "/usr/bin/startup"   About an hour ago   Up About an hour    443/tcp, 8800/tcp, 9002/tcp, 0.0.0.0:8021->21/tcp, 0.0.0.0:8022->22/tcp, 0.0.0.0:8080->80/tcp   sharp_mirzakhani

```

Now we stop the image, because we need te restart it with the right folder mapping:

``` bash 
$ docker kill sharp_mirzakhani
```

Then we start up a new image, this time **mapping a local folder containing our tools to a folder within the docker image**. For this we use the `docker -v` argument, take a look at `docker --help` to learn more about the available options. Although, we do not 
deviate much from the most basic options to make this as *simple* as possible.

Open up your powershell when you have no more docker processes running and run the previous `docker run` command with additional path information. Change the `c:/users/stokkumrmv/GitLab/testing_galaxy_aug_2018/mytool` to the relevant path you would like to use. 

``` bash
docker run -d -p 8080:80 -p 8021:21 -p 8022:22 -v c:/users/stokkumrmv/GitLab/testing_galaxy_aug_2018/mytool:/local_tools bgruening/galaxy-stable
```

*verwijder later* 
``` bash
docker run -d -p 8080:80 -p 8021:21 -p 8022:22 -v c:/users/twillerthtlv/GitLab/Galaxy/inst/gal
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

Now you can use `bash` to *get into* the docker image, containing a running Galaxy instance. We use `docker exec` with option `-it` to get an *interactive* environment pointed at the galaxy instance. Then from there we run `bash` to open up bash, the Unix command 
line used in Linux and Mac OS.

(Remember you can use `docker ps` to find the names of running galaxy instances.)

``` bash
PS C:\Users\stokkumrmv> docker exec -it sharp_mirzakhani bash
root@344375995c84:/galaxy-central#
```

See how you changed the folder from `PS ...` (PowerShell) to `root@...` (a unix directory). This means you *entered* the docker image! Now, note that this is a completely separate operating system from your own Windows system. The only things that are shared are 
the ports that we opened up ()

Now, while you are *in* this docker image you should get used to the Linux command line. Most basically- use `ls` to list files, `cd` to change directories.

### Finding your local folder in Docker

Now we are in /home/galaxy-central, the starting folder of this galaxy instance. We mapped a local folder to `/local_tools/`, a folder containing some local code or functions and tools.

(We did this with `docker run -d -p 8080:80 -p 8021:21 -p 8022:22 -v c:/users/stokkumrmv/GitLab/testing_galaxy_aug_2018/mytool:/local_tools bgruening/galaxy-stable`)

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

Please notice that we are not experts with Docker and as such have not made our own DockerFile. Although we have learned a lot about them partly from learning how [Aurora Galaxy Tools](https://github.com/statonlab/aurora-galaxy-tools) are made. This repository 
includes a dockerfile at <https://github.com/statonlab/aurora-galaxy-tools/tree/master/docker-aurora-rnaseq> . Following the small number of steps in this dockerfile very closely can be a great way to learn how to install our own tools to a custom Galaxy docker 
image hosted on a server. Since this DockerFile does not contain many steps we are confident that we can adjust this image to our own, very similar, needs.

We still need Planemo to install and build tools, so from within the Galaxy docker image, we use `pip` to install new packages. Pip is a package manager used for python packages. We can use pip from the command line to install python packages, like Planemo and 
Galaxy!

``` bash
pip install --upgrade pip
pip install planemo         
```

Now that we have Planemo, we can test our XML function. First, we can do `lint`, which is a strict test to check wheter all required parameters are found in the XML, such as inputs and help.
The Planemo’s lint (or just l) command will review tool for XML validity and obvious mistakes.

If we are in the correct folder (`local_tools`) the following command is suffice:

``` bash
planemo l
```

Planemo will check for valid XML tools by itself and will run its test. If you have more than a single XML file you would like to test, you can specify it with:

``` bash
planemo lint TestTool.xml
```

We would like to see:

``` bash
File validates against XML schema.
```

From experience I know this test can be a bit overstrict: meaning that when a certain parameter is not supplied (such as citations or the help) it is still possible that your tool will work.

Now we can do a functional test. This is done with the `test` command, which works the same as lint (Planemo finds the tool itself or you specify which one you want tested).
The test function gives a lot of output, since by default Planemo will setup its own Galaxy instance (I don't know a proper work around yet).

``` bash
planemo t
```

In addition to the in console display of test results as red (failing) or green (passing), Planemo also creates an HTML report for the test results by default. Many more test report options are available. See planemo test --help for more options, as well as the test_reports command.

If the test passed, you can upload your XML tool file to a [public toolshed](https://testtoolshed.g2.bx.psu.edu/). Create an account, log in, upload the tool. 
When added to this public toolshed, it is ready to be used in the public version of Galaxy. 

Go to our [local Galaxy instance](http://127.0.0.1:8080), login as Admin using 'admin@galaxy.org' as User and 'admin' as password.
After logging in, click 'Admin' in the upper right corner, then 'Installing new tools' under 'Tool Management'.
The dropdown menu under 'Accessible Galaxy Tools Sheds' should have the test toolshed as an option, from where you can browse to our newly added tool.


Optional stuff
--------------
Supposedly, planemo can serve some code:

``` bash
planemo s
``` 

but this does not seem to work...

Additionally, it [should be possible](https://galaxyproject.org/admin/tools/add-tool-tutorial/) to add the tool manually by updateing `tool_conf.xml` located in the `config` folder of Galaxy. 
By adding:

``` bash
 <section name="MyTools" id="mTools">
    <tool file="myTools/toolExample.xml" />
 </section> 
```

it should show up in the available tools of [our own Galaxy instance](http://127.0.0.1:8080)
