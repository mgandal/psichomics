printPaste <- function(...) print(paste(...))

#' Returns the date format used by the Firehose API
#'
#' @return Named list with Firehose API's date formats
#' @export
#'
#' @examples
#' format <- getFirehoseDateFormat()
#' 
#' # date format to use in a query to Firehose API
#' format$query
#' 
#' # date format to parse a date in a response from Firehose API
#' format$response
getFirehoseDateFormat <- function() {
    query <- "%Y_%m_%d"
    response <- "%a, %d %b %Y %H:%M:%S" 
    return(list(query=query, response=response))
}

#' Check if the Firehose API is running
#'
#' The Firehose API is running if it returns the status condition 200; if
#' this is not the status code obtained from the API, the function will raise a
#' warning with the status code and a brief explanation.
#'
#' @return Invisible TRUE if the Firehose API is working; otherwise, raises a
#' warning
#' @export
#'
#' @importFrom httr GET warn_for_status http_error
#'
#' @examples
#' isFirehoseUp()
isFirehoseUp <- function() {
    link <- paste0("http://firebrowse.org/api/v1/Metadata/HeartBeat")
    heartbeat <- tryCatch(GET(link, query=list(format="json")), error=return)
    if ("simpleError" %in% class(heartbeat)) {
        return(FALSE)
    } else if (http_error(heartbeat)) {
        warn_for_status(heartbeat, "reach Firehose API")
        return(FALSE)
    } else {
        return(TRUE)
    }
}

#' Query the Firehose API for TCGA data
#'
#' @param format Character: response format as JSON (default), CSV or TSV
#' @param date Character: dates of the data retrieval by Firehose (by default,
#' it uses the most recent data available)
#' @param cohort Character: abbreviation of the cohorts (by default, returns
#' data for all cohorts)
#' @param data_type Character: data types (optional)
#' @param tool Character: data produced by the selected Firehose tools
#' (optional)
#' @param platform Character: data generation platforms (optional)
#' @param center Character: data generation centers (optional)
#' @param level Integer: data levels (optional)
#' @param protocol Character: sample characterization protocols (optional)
#' @param page Integer: page of the results to return (optional)
#' @param page_size Integer: number of records per page of results; max is 2000
#' (optional)
#' @param sort_by String: column used to sort the data (by default, it sorts by
#' cohort)
#'
#' @return Response from the Firehose API (it needs to be parsed)
#' @export
#'
#' @importFrom httr GET
#'
#' @examples
#' cohort <- getFirehoseCohorts()[1]
#' queryFirehoseData(cohort = cohort, data_type = "mRNASeq")
#' 
#' # Querying for data from a specific date
#' dates <- getFirehoseDates()
#' dates <- format(dates, getFirehoseDateFormat()$query)
#' 
#' queryFirehoseData(date = dates[2], cohort = cohort)
queryFirehoseData <- function(format = "json", date = NULL, cohort = NULL, 
                              data_type = NULL, tool = NULL, platform = NULL,
                              center = NULL, level = NULL, protocol = NULL,
                              page = NULL, page_size = NULL, sort_by = NULL) {
    # Only allow these response formats
    format <- match.arg(format, c("json", "csv", "tsv"))
    
    # Process the parameters of the query
    labels <- list("format", "date", "cohort", "data_type", "tool", "platform",
                   "center", "level", "protocol", "page", "page_size",
                   "sort_by")
    query <- lapply(labels, dynGet)
    names(query) <- labels
    query <- Filter(Negate(is.null), query)
    
    # Collapse items with a comma to query for multiple items
    query <- lapply(query, paste, collapse = ",") 
    
    # Query the API
    response <- GET("http://firebrowse.org", query = query,
                    path = "api/v1/Archives/StandardData")
    return(response)
}

#' Query the Firehose API for metadata and parse the response
#'
#' @param type Character: metadata to retrieve
#' @param ... Character: parameters to pass to query (optional)
#'
#' @return List with parsed JSON response
#' @export
#'
#' @importFrom httr GET content
#' @importFrom jsonlite fromJSON
#'
#' @examples
#' parseFirehoseMetadata("Dates")
#' parseFirehoseMetadata("Centers")
#' parseFirehoseMetadata("HeartBeat")
#' 
#' # Get the abbreviation and description of all cohorts available
#' parseFirehoseMetadata("Cohorts")
#' # Get the abbreviation and description of the selected cohorts
#' parseFirehoseMetadata("Cohorts", cohort = c("ACC", "BRCA"))
parseFirehoseMetadata <- function(type, ...) {
    # Remove NULL arguments
    args <- Filter(Negate(is.null), list(...))
    
    # Query multiple items by collapsing them with a comma
    if (length(args) > 0)
        args <- lapply(args, paste, collapse = ",")
    
    # Query the given link and parse the response
    link <- paste0("http://firebrowse.org/api/v1/Metadata/", type)
    response <- GET(link, query = c(format = "json", args))
    response <- fromJSON(content(response, "text", encoding = "UTF8"))
    return(response)
}

#' Query the Firehose API for the datestamps of the data available and parse the
#' response
#'
#' @return Date with datestamps of the data available
#' @export
#'
#' @examples
#' getFirehoseDates()
getFirehoseDates <- function() {
    dates <- parseFirehoseMetadata("Dates")$Dates
    format <- getFirehoseDateFormat()
    dates <- as.Date(dates, format$query)
    return(dates)
}

#' Query the Firehose API for the cohorts available
#'
#' @param cohort Character: filter by given cohorts (optional)
#'
#' @return Character with cohort abbreviations (as values) and description (as 
#' names)
#' @export
#'
#' @examples
#' getFirehoseCohorts()
getFirehoseCohorts <- function(cohort = NULL) {
    response <- parseFirehoseMetadata("Cohorts", cohort=cohort)
    cohorts <- response$Cohorts[[2]]
    names(cohorts) <- response$Cohorts[[1]]
    return(cohorts)
}

#' Download files to a given directory
#'
#' @param url Character: download links
#' @param folder Character: directory to store the downloaded archives
#' @param ... Extra parameters passed to the download function
#' @param download Function to use to download files
#' @param progress Function to show the progress (default is printPaste)
#' 
#' @importFrom utils download.file
#' 
#' @return Invisible TRUE if every file was successfully downloaded
#' @export
#'
#' @examples
#' \dontrun{
#' url <- paste0("https://unsplash.it/400/300/?image=", 570:572)
#' downloadFiles(url, "~/Pictures")
#' 
#' # Download without printing to console
#' downloadFiles(url, "~/Pictures", quiet = TRUE)
#' }
downloadFiles <- function(url, folder, progress = printPaste,
                          download = download.file, ...) {
    destination <- file.path(folder, basename(url))
    for (i in seq_along(url)) {
        progress("Downloading file", detail = basename(url[i]), i, length(url))
        download(url[i], destination[i], ...)
    }
    print("Downloading completed")
    return(destination)
}

#' Compute the 32-byte MD5 hashes of one or more files and check with given md5
#' file
#'
#' @param filesToCheck Character: files to calculate and match MD5 hashes
#' @param md5file Character: file containing correct MD5 hashes
#'
#' @importFrom digest digest
#' @importFrom utils read.table
#'
#' @return Logical vector showing TRUE for files with matching md5sums and FALSE
#' for files with non-matching md5sums
#' @export
checkIntegrity <- function(filesToCheck, md5file) {
    md5sums <- digest(file = filesToCheck)
    md5table <- read.table(md5file, stringsAsFactors = FALSE)[[1]]
    return(md5sums %in% md5table)
}

#' Prepares Firehose archives in a given directory
#'
#' Checks Firehose archives' integrity using the MD5 files, extracts the content
#' of the archives and removes the original downloaded archives.
#'
#' @param archive Character: path to downloaded archives
#' @param md5 Characater: path to MD5 files of each archive
#' @param folder Character: local folder where the archives should be stored
#' 
#' @importFrom utils untar
#' 
#' @return Invisible TRUE if successful
#' @export
#'
#' @examples
#' file <- paste0(
#'     "http://gdac.broadinstitute.org/runs/stddata__2015_11_01/data/",
#'     "ACC/20151101/gdac.broadinstitute.org_ACC.",
#'     "Merge_Clinical.Level_1.2015110100.0.0.tar.gz")
#' \dontrun{
#' prepareFirehoseArchives(folder = "~/Downloads", archive = file,
#'                         md5 = paste0(file, ".md5"))
#' }
prepareFirehoseArchives <- function(archive, md5, folder) {
    archive <- file.path(folder, archive)
    md5 <- file.path(folder, md5)
    
    # Check integrety of the downloaded archives with the MD5 files
    ## TODO(NunoA): don't assume every file has the respective MD5 file
    validFiles <- simplify2array(Map(checkIntegrity, archive, md5))
    
    ## TODO(NunoA): Should we try to download the invalid archives again?
    ## What if they're constantly invalid? Only try n times before giving up?
    if (!all(validFiles)) {
        warning("The MD5 hashes failed when checking the following files:\n",
                paste(archive[!validFiles], collapse = "\n\t"))
    }
    
    ## TODO(NunoA): Check if path.expand works in Windows
    # Extract the contents of the archives to the same folder
    invisible(lapply(archive, untar, exdir = path.expand(folder)))
    
    # Remove the original downloaded files
    invisible(file.remove(archive, md5))
    return(invisible(TRUE))
}

#' Retrieve URLs from a response to a Firehose data query
#'
#' @param res Response from httr::GET to a Firehose data query
#'
#' @return Named character with URLs
#' @export
#' 
#' @importFrom jsonlite fromJSON
#' @importFrom httr content
#'
#' @examples
#' res <- queryFirehoseData(cohort = "ACC")
#' url <- parseUrlsFromFirehoseResponse(res)
parseUrlsFromFirehoseResponse <- function(res) {
    # Parse the query response
    parsed <- content(res, "text", encoding = "UTF8")
    parsed <- fromJSON(parsed)[[1]]
    parsed$date <- as.Date(parsed$date,
                           format = getFirehoseDateFormat()$response)
    
    # Get cohort names
    cohort <- getFirehoseCohorts()
    cohort <- cohort[parsed$cohort]
    
    ## TODO(NunoA): maybe this could be simplified?
    # Split URLs from response by cohort and datestamp
    url <- split(parsed$url, paste(cohort, format(parsed$date, "%Y-%m-%d")))
    url <- lapply(url, unlist)
    link <- unlist(url)
    names(link) <- rep(names(url), vapply(url, length, numeric(1)))
    return(link)
}

#' Load Firehose folders
#'
#' Loads the files present in each folder as a data.frame.
#' 
#' @note For faster execution, this function uses the \code{readr} library. This
#' function ignores subfolders of the given folder (which means that files 
#' inside subfolders are NOT loaded).
#'
#' @include formats.R
#'
#' @param folder Character: folder(s) in which to look for Firehose files
#' @param exclude Character: files to exclude from the loading
#' @param progress Function to show the progress (default is printPaste)
#' 
#' @return List with loaded data.frames
#' @export
loadFirehoseFolders <- function(folder, exclude="", progress = printPaste) {
    # Retrieve full path of the files inside the given folders
    files <- dir(folder, full.names=TRUE)
    
    # Exclude subdirectories and undesired files
    files <- files[!dir.exists(files)]
    exclude <- paste(exclude, collapse = "|")
    if (exclude != "") files <- files[!grepl(exclude, files)]
    
    # Try to load files and remove those with 0 rows
    loaded <- list()
    formats <- loadFileFormats()
    for (each in seq_along(files)) {
        progress("Processing file", detail = basename(files[each]), each, 
                 length(files))
        loaded[[each]] <- parseValidFile(files[each], formats)
    }
    names(loaded) <- sapply(loaded, attr, "tablename")
    loaded <- Filter(length, loaded)
    return(loaded)
}

#' Downloads and processes data from the Firehose API and loads it into R
#' 
#' @param folder Character: directory to store the downloaded archives (by
#' default, it saves in the user's "Downloads" folder)
#' @param exclude Character: files and folders to exclude from downloading and
#' from loading into R (by default, it excludes ".aux.", ".mage-tab." and
#' "MANIFEST.TXT" files)
#' @param ... Extra parameters to be passed to \code{\link{queryFirehoseData}}
#' @param progress Function to show the progress (default is printPaste)
#' @param output Output from the Shiny server function
#' 
#' @include formats.R
#' @importFrom tools file_ext file_path_sans_ext
#' @importFrom httr stop_for_status
#' 
#' @export
#' @examples 
#' \dontrun{
#' loadFirehoseData(cohort = "ACC", data_type = "Clinical")
#' }
loadFirehoseData <- function(folder = "~/Downloads",
                             exclude = c(".aux.", ".mage-tab.", "MANIFEST.txt"),
                             ..., progress = printPaste, output=output) {
    ## TODO(NunoA): Check if the default folder works in Windows
    # Query Firehose and get URLs for archives
    res <- queryFirehoseData(...)
    stop_for_status(res)
    url <- parseUrlsFromFirehoseResponse(res)
    
    # Don't download specific items
    exclude <- paste(escape(exclude), collapse = "|")
    url <- url[!grepl(exclude, url)]
    
    # Get the file name without extensions
    md5  <- file_ext(url) == "md5"
    base <- basename(url)
    base[!md5] <- file_path_sans_ext(base[!md5], compression = TRUE)
    
    # Check which files are missing from the given directory
    downloadedFiles <- list.files(folder)
    downloadedMD5   <- file_ext(downloadedFiles) == "md5"
    
    missing <- logical(length(base))
    missing[md5]  <- !base[md5] %in% downloadedFiles[downloadedMD5]
    
    possibleExtensions <- lapply(base[!md5], paste0, c("", ".tar", ".tar.gz"))
    missing[!md5] <- vapply(possibleExtensions, function (i)
        !any(i %in% downloadedFiles[!downloadedMD5]), FUN.VALUE = logical(1))
    
    if (sum(missing[!md5]) > 0) {
        # downloadFiles(missing, folder, progress)
        
        # If there aren't non-MD5 files in the given directory, download
        # missing files
        progress(divisions = 1)
        print("Triggered the download of files")
        
        iframe <- function(url) 
            tags$iframe(width=1, height=1, frameborder=0, src=url)
        output$iframeDownload <- renderUI(lapply(url[missing], iframe))
        return(NULL)
    } else {
        # Check if there are folders to unarchive
        archives <- unlist(lapply(possibleExtensions, function (i)
            i[i %in% downloadedFiles[!downloadedMD5]]))
        tar <- grepl(".tar", archives, fixed = TRUE)
        
        # Split folders by the cohort type and date
        categories <- names(url[!md5])
        folders <- file.path(folder, base[!md5])
        folders <- split(folders, categories)
        
        if (length(archives[tar]) > 0) {
            progress("Extracting archives...", divisions = 1 + length(folders))
            # Extract the content, check the intergrity and remove archives
            prepareFirehoseArchives(archives[tar], base[md5][tar], folder)
            progress("Archives prepared")
        } else {
            # Divide the progress bar by the number of folders to load
            progress(divisions = length(folders))   
        }
        
        # Load the files
        loaded <- lapply(folders, loadFirehoseFolders, exclude, progress)
        return(loaded)
    }
}

#' @importFrom R.utils capitalize
getFirebrowseDataChoices <- function() {
    choices <- c(paste0(c("junction", "exon"),
                        "_quantification"), "Preprocess",
                 paste0("RSEM_", c("isoforms", "genes")),
                 paste0(c("junction", "gene", "exon"),
                        "_expression"), "genes_normalized")
    names(choices) <- capitalize(gsub("_", " ", choices))
    return(choices)
}

#' Creates a UI set with options to add data from TCGA/Firehose
#' @importFrom shinyBS bsTooltip
#' @return A UI set that can be added to a UI definition
addTCGAdata <- function(ns) {
    if (isFirehoseUp()) {
        cohorts <- getFirehoseCohorts()
        acronyms <- names(cohorts)
        names(acronyms) <- sprintf("%s (%s)", cohorts, names(cohorts))
        
        dates <- as.character(getFirehoseDates())
        
        tagList(
            uiOutput(ns("firebrowseDataModal")),
            uiOutput(ns("pathAutocomplete")),
            uiOutput(ns("iframeDownload")),
            selectizeInput(ns("firehoseCohort"), "Cohort", acronyms,
                           multiple = TRUE, selected = c("ACC"),
                           options = list(placeholder = "Select cohort(s)")),
            selectizeInput(ns("firehoseDate"), "Date", dates, multiple = TRUE,
                           selected = dates[1], options = list(
                               placeholder = "Select sample date")),
            selectizeInput(ns("firehoseData"), "Data type",
                           c("Clinical", getFirebrowseDataChoices()), 
                           multiple = TRUE, selected = "Clinical",
                           options = list(
                               placeholder = "Select data types")),
            textAreaInput(ns("dataFolder"), "Folder to store the data",
                          value = "~/Downloads/",
                          placeholder = "Insert data folder"),
            bsTooltip(ns("dataFolder"), placement = "right",
                      options = list(container = "body"),
                      "Data not available in this folder will be downloaded."),
            actionButton(class = "btn-primary", type = "button",
                         ns("getFirehoseData"), "Get data"))
    } else {
        list(icon("exclamation-circle"),
             "Firehose seems to be offline at the moment.")
    }
}

#' @importFrom shinyBS bsCollapse bsCollapsePanel
firebrowseUI <- function(id, panel) {
    ns <- NS(id)
    
    panel(
        style = "info",
        title = list(icon("plus-circle"), "Add TCGA/Firehose data"),
        value = "Add TCGA/Firehose data", addTCGAdata(ns))
}

#' Set data from Firehose
#' @param input Shiny input
#' @param output Shiny output
#' @param session Shiny session
#' @param replace Boolean: replace loaded data? TRUE by default
#' @importFrom shinyjs disable enable 
setFirehoseData <- function(input, output, session, replace=TRUE) {
    disable("getFirehoseData")
    
    data <- input$firehoseData
    datasets <- getFirebrowseDataChoices()
    # Data types to load
    data_type <- c(data[!data %in% datasets], "mRNASeq")
    # Datasets to ignore
    ignore <- datasets[!datasets %in% data]
    
    # Load data from Firehose
    data <- loadFirehoseData(
        folder = input$dataFolder,
        cohort = input$firehoseCohort,
        date = gsub("-", "_", input$firehoseDate),
        data_type = data_type,
        exclude = c(".aux.", ".mage-tab.", ignore),
        progress = updateProgress,
        output = output)
    
    if (!is.null(data)) {
        if(replace)
            setData(data)
        else
            setData(c(getData(), data))
    }
    
    closeProgress()
    enable("getFirehoseData")
}

firebrowseServer <- function(input, output, session, active) {
    ns <- session$ns
    
    # # The button is only enabled if it meets the conditions that follow
    # observe(toggleState("acceptFile", input$species != ""))
    
    # Update available clinical data attributes to use in a formula
    output$pathAutocomplete <- renderUI({
        checkInside <- function(path, showFiles=FALSE) {
            if (substr(path, nchar(path), nchar(path)) == "/") {
                content <- list.files(path, full.names = TRUE)
            } else {
                content <- list.files(dirname(path), full.names = TRUE)
            }
            
            # Show only directories if showFiles is FALSE
            if (!showFiles) content <- content[dir.exists(content)]
            return(basename(content))
        }
        
        textComplete(ns("dataFolder"), checkInside(input$dataFolder),
                     char=.Platform$file.sep)
    })
    
    # Check if data is already loaded and ask the user if it should be replaced
    observeEvent(input$getFirehoseData, {
        if (!is.null(getData()))
            loadedDataModal(session,
                            "firebrowseDataModal",
                            "firebrowseReplace",
                            "firebrowseAppend")
        else
            setFirehoseData(input, output, session)
    })
    
    # Load data when the user presses to replace data
    observeEvent(input$firebrowseReplace,
                 setFirehoseData(input, output, session, replace=TRUE))
    
    # Load data when the user presses to load new data (keep previously loaded)
    observeEvent(input$firebrowseAppend,
                 setFirehoseData(input, output, session, replace=FALSE))
}

attr(firebrowseUI, "loader") <- "data"
attr(firebrowseServer, "loader") <- "data"