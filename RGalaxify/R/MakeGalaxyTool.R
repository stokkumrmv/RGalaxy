#' Create a galaxy tool from a function in this package
#'
#' Create a galaxy tool consisting of an XML file and an R script.
#' The R script should be a function defintion of a documented function, using
#' \pkg{roxygen2}. The documentation is then used to make the tool definition.
#' This function will also attempt to create a functional test, although this
#' is likely to fail the first time since you need to add the data to the right
#' directory.
#'
#' @param func Function to generate a script of. Needs to be exported by this package.
#' @param galaxyHome (OPTIONAL) Galaxy home folder, don't change unless you know what you're doing.
#' @param toolDir (OPTIONAL) tool directory relative to 'galaxyHome/tools/', use this to group tools within 1 folder.
#'
#' @return Output from the functional test of \code{func}
#' @export
#'
#' @examples
#' # Set your working directory to the root of this package
#' #   Make sure you have cloned this package to run this example.
#' \dontrun{
#' MakeGalaxyTool(CreateDESeqData)
#' }
MakeGalaxyTool <- function(funcName, galaxyHome = "inst/galaxy", toolDir = "mytool") {
  require(RGalaxy)

  # funcName <- deparse(substitute(func))

  if (!dir.exists(galaxyHome)) {
    warning("galaxyHome '%s' does not exist and will be created",
            galaxyHome)
    dir.create(galaxyHome, recursive = T)
  }

  # file.copy(system.file("galaxy", "tool_conf.xml", package="RGalaxy"),
  #           file.path(galaxyHome, "tool_conf.xml"), overwrite=FALSE)

  functionalTestDirectory <- "inst/functionalTests"
  funcTestDirectory <- file.path(functionalTestDirectory, funcName)
  message("Trying to create functional tests...")
  funTest <- CreateFunctionalTest(funcName, functionalTestDirectory)

  mywd <- getwd()

  message("Building galaxy tool...")
  galaxy(funcName,
         galaxyConfig=GalaxyConfig(galaxyHome, toolDir,
                                   "Local tools", toolDir),
         RserveConnection=NULL,
         functionalTestDirectory = functionalTestDirectory)

  # setwd(file.path(functionalTestDirectory, funcName))
  # runFunctionalTest(CreateDESeqData, file.path(functionalTestDirectory, funcName))
  # setwd(mywd)

  # Verify that tool was created
  if (file.exists(file.path(galaxyHome, "tools", toolDir, paste0(funcName, ".xml")))) {
    message(sprintf(("Success! Galaxy tool created at %s"),
                    file.path(galaxyHome, "tools", toolDir, paste0(funcName, ".xml"))))
  }

  # Rewrite XML tool definition
  new.xml <- RewriteToolXML(funcName, galaxyHome, toolDir)


  new.script <- RewriteToolScript(funcName, galaxyHome, toolDir)


  return(funTest)
}

#' Get test parameters for function to make into a Galaxy tool
#'
#' The functional test needs to know which parameters to pass to the tool.
#' For this we use the functional tests from the \pkg{RGalaxy} package.
#'
#' @param func Function to generate tool of
#'
#' @details
#' The output can be used to debug the functional test. It will show you
#' which files are expected to be in the /inst/functionalTests/func folder.
#' NOTE: DUE TO SOME BUGGY BEHAVIOR IN \pkg{RGalaxy} THE INPUT/OUTPUT FILES DO
#' NOT HAVE FILE EXTENSIONS!
#'
#' @return List of used functional test parameters.
#' @export
#'
GetGalaxyTestParams <- function(funcName, functionalTestDirectory = NULL) {
  func <- get(funcName)
  funcInfo <- list()
  testVals <- list()
  outVals <- list()
  for (param in names(formals(func))) {
    funcInfo[[param]] <- getFuncInfo(func, param)
  }

  outfiles <- list()
  params <- list()
  for (info in funcInfo) {
    paramEval <- eval(formals(funcName)[[info$param]])
    if (info$type == "GalaxyOutput") {
      outfiles[[info$param]] <- tempfile()
      # params[[info$param]] <- file.path(funcName, eval(info$default)[1])
      params[[info$param]] <- eval(info$default)[1]
    }
    else if (info$type == "GalaxyInputFile") {
      # params[[info$param]] <- file.path(funcName, info$testValues)
      params[[info$param]] <- info$testValues
    } else {
      params[[info$param]] <- info$testValues
      if (length(info$testValues) == 0) {
        isRequired <- attr(paramEval, "required")
        if (isRequired) {
          stop(sprintf("No test values defined for parameter %s!", info$param))
        } else {
          param[[info$param]] <- paramEval[1]
          # if (is.na(param$Eval[1])) param[[info$param]] <- NULL
        }
      }
    }
    if (is.null(params[[info$param]])) {
      stop(sprintf("No test values defined for parameter %s!", info$param))
    }
  }
  return(params)
}

#' Create functional test output for tool
#'
#' This function creates the functional test output for a given function.
#' However, if the tool needs input files then these are expected to be present
#' in the \code{functionalTestDirectory/func} directory. To see which files exactly
#' are expected, use the \code{\link{GetGalaxyTestParams}} function.
#'
#' @param func Function name to create a tool of, as character value.
#' @param functionalTestDirectory functional test directory, recommended to leave as default.
#'
#' @return Logical of whether the functional test was created or not
#' @export
#'
#' @examples
#' # Set your working directory to the root of this package
#' #   Make sure you have cloned this package to run this example.
#' \dontrun{
#' CreateFunctionalTest("CreateDESeqData")
#' }
CreateFunctionalTest <- function(funcName, functionalTestDirectory = "tools/mytool/test-data") {
  # funcFormals <- formals(func)
  func <- get(funcName)
  # funcTestDirectory <- file.path(functionalTestDirectory, funcName)
  # if (!dir.exists(funcTestDirectory)) {
  #   dir.create(funcTestDirectory, recursive = T)
  #   message(sprintf("Created '%s' directory for functional test", funcTestDirectory))
  # } else {
  #   message(sprintf("Test directory '%s' already exists. Overwriting results!", funcTestDirectory))
  # }
  #
  mywd <- getwd()
  setwd(functionalTestDirectory)

  funcOutput <- try({
    params <- GetGalaxyTestParams(funcName, functionalTestDirectory)
    print(params)
    do.call(func, params)
  })

  if (class(funcOutput)=="try-error") {
    setwd(mywd)
    warning(sprintf("Functional test failed! Error was: %s", as.character(funcOutput)))
    return(FALSE)
  }
  setwd(mywd)
  return(TRUE)
}

#' Convert List to XML
#'
#' @author David LeBauer, Carl Davidson, Rob Kooper
#'
#'
#' Can convert list or other object to an xml object using xmlNode
#' @param item XML in a list (as returned by \code{\link[XML]{xmlToList}})
#' @param tag character value giving xml tag
#' @return xmlNode
#' @export
#'
listToXml <- function(item, tag = "tool") {
  require(XML)

  # just a textnode, or empty node with attributes
  if(typeof(item) != 'list') {
    if (length(item) > 1) {
      xml <- xmlNode(tag)
      for (name in names(item)) {
        xmlAttrs(xml)[[name]] <- item[[name]]
      }
      return(xml)
    } else {
      return(xmlNode(tag, item))
    }
  }

  # create the node
  if (identical(names(item), c("text", ".attrs"))) {
    # special case a node with text and attributes
    xml <- xmlNode(tag, item[['text']])
  } else {
    # node with child nodes
    xml <- xmlNode(tag)
    for(i in 1:length(item)) {
      if (names(item)[i] != ".attrs") {
        xml <- append.xmlNode(xml, listToXml(item[[i]], names(item)[i]))
      }
    }
  }

  # add attributes to node
  attrs <- item[['.attrs']]
  for (name in names(attrs)) {
    xmlAttrs(xml)[[name]] <- attrs[[name]]
  }
  return(xml)
}

#' Rewrite XML generated by \pkg{RGalaxy}
#'
#' @param funcName
#' @param galaxyHome
#' @param toolDir
#'
#' @return
#' @export
#'
RewriteToolXML <- function(funcName,
                           galaxyHome = "inst/galaxy",
                           toolDir = "mytool") {
  xml.file <- file.path(galaxyHome, "tools", toolDir, paste0(funcName, ".xml"))
  if (!file.exists(xml.file)) stop(sprintf("XML tool file '%s' not found", xml.file))

  xml.parsed <- xmlParse(xml.file)
  xml.list <- xmlToList(xml.parsed)

  xml.command <- xml.list$command
  command.text <- xml.command$text
  # Adjust command text
  command.pre <- paste0(c("  ######### one important path:",
                          "    ######### 1. path to tool installation directory",
                          "    export TOOL_INSTALL_DIR='${__tool_directory__}' &&\n"),
                        collapse = "\n")

  command.text <- gsub(funcName, paste0("'$__tool_directory__/", funcName), command.text)
  command.new <- paste0(c(command.pre, "\n    Rscript ", command.text))
  command.new <- sub("2>&1([^2>&1]*)$", "", command.new)
  command.new <- xmlCDataNode(command.new)

  xml.list$command$text <- command.new
  xml.list$command$.attrs <- c(detect_errors="exit_code")

  xml.output <- listToXml(xml.list, tag = "tool")
  saveXML(xml.output, file = xml.file, prefix = "")
  message(sprintf("Rewrote the '%s' xml tool defintion", xml.file))
  return(xml.output)
}

#' Rewrite R script generated by \pkg{RGalaxy}
#'
#' @param funcName
#' @param galaxyHome
#' @param toolDir
#'
#' @return
#' @export
#'
RewriteToolScript <- function(toolScript,
                              toolPath = "tools/mytool",
                              generate_runnable = T) {
  if (!file.exists(toolScript)) stop(sprintf("Tool R script '%s' not found", toolScript))

  # Load some required libraries for every tool.
  scriptPre <- paste0(c("require(RGalaxy)", "require(optparse)"), collapse = "\n")

  # Get function definition as character vector
  #   The last line is <environment: namespace:...> - which we'll remove.
  scriptBody <- paste0(readLines(toolScript), collapse = "\n")
  # script.body <- paste0(script.body[-length(script.body)], collapse = "\n")
  # script.body <- paste0(funcName, " <- ", script.body)

  # After the function defintion we use the 'generate_runnable.R' script
  scriptPost <- paste0(c(sprintf("fun_name=\"%s\"", funcName),
                        "source(file.path(Sys.getenv(\"TOOL_INSTALL_DIR\"), \"generate_runnable.R\"))"),
                        collapse = "\n")

  newScript <- paste0(c(scriptPre,
                       scriptBody,
                       scriptPost),
                       collapse = "\n\n")

  writeLines(newScript, file.path(toolPath, toolScript))
  message(sprintf("Wrote the '%s' tool R script", toolScript))

  if (generate_runnable) {
    if (!file.exists(file.path(toolPath, "generate_runnable.R"))) {
      if (file.exists("generate_runnable.R")) {
        file.copy("generate_runnable.R", file.path(toolPath, "generate_runnable.R"))
      } else stop("generate_runnable.R not found in current working directory.")
    }
  }

  return(newScript)
}

