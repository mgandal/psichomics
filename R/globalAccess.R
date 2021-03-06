## Functions to get and set globally accessible variables

#' @include utils.R 
NULL

# Global variable with all the data of a session
sharedData <- reactiveValues()

#' Get global data
#' @return Variable containing all data of interest
getData <- reactive(sharedData$data)

#' Get if history browsing is automatic
#' @return Boolean: is navigation of browser history automatic?
getAutoNavigation <- reactive(sharedData$autoNavigation)

#' Get number of cores to use
#' @return Numeric value with the number of cores to use
getCores <- reactive(sharedData$cores)

#' Get number of significant digits
#' @return Numeric value regarding the number of significant digits
getSignificant <- reactive(sharedData$significant)

#' Get number of decimal places
#' @return Numeric value regarding the number of decimal places
getPrecision <- reactive(sharedData$precision)

#' Get selected alternative splicing event's identifer
#' @return Alternative splicing event's identifier as a string
getEvent <- reactive(sharedData$event)

#' Get available data categories
#' @return Name of all data categories
getCategories <- reactive(names(getData()))

#' Get selected data category
#' @return Name of selected data category
getCategory <- reactive(sharedData$category)

#' Get data of selected data category
#' @return If category is selected, returns the respective data as a data frame;
#' otherwise, returns NULL
getCategoryData <- reactive(
    if(!is.null(getCategory())) getData()[[getCategory()]])

#' Get selected dataset
#' @return List of data frames
getActiveDataset <- reactive(sharedData$activeDataset)

#' Get clinical data of the data category
#' @return Data frame with clinical data
getClinicalData <- reactive(getCategoryData()[["Clinical data"]])

#' Get junction quantification data
#' @note Needs to be called inside a reactive function
#' 
#' @param category Character: data category (e.g. "Carcinoma 2016"); by default,
#' it uses the selected data category
#' @return List of data frames of junction quantification
getJunctionQuantification <- function(category=getCategory()) {
    if (!is.null(category)) {
        data <- getData()[[category]]
        match <- sapply(data, attr, "dataType") == "Junction quantification"
        if (any(match)) return(data[match])
    }
}

#' Get alternative splicing quantification of the selected data category
#' @return Data frame with the alternative splicing quantification
getInclusionLevels <- reactive(getCategoryData()[["Inclusion levels"]])

#' Get sample information of the selected data category
#' @return Data frame with sample information
getSampleInfo <- reactive(getCategoryData()[["Sample metadata"]])

#' Get data from global data
#' @param ... Arguments to identify a variable
#' @param sep Character to separate identifiers
#' @return Data from global data
getGlobal <- function(..., sep="_") sharedData[[paste(..., sep=sep)]]

#' Get the identifier of patients for a given category
#' @note Needs to be called inside a reactive function
#' 
#' @param category Character: data category (e.g. "Carcinoma 2016"); by default,
#' it uses the selected data category
#' 
#' @return Character vector with identifier of patients
getPatientId <- function(category = getCategory())
    getGlobal(category, "patients")

#' Get the identifier of samples for a given category
#' @note Needs to be called inside a reactive function
#' 
#' @param category Character: data category (e.g. "Carcinoma 2016"); by default,
#' it uses the selected data category
#' 
#' @return Character vector with identifier of samples
getSampleId <- function(category = getCategory())
    getGlobal(category, "samples")

#' Get the table of differential analyses of a data category
#' @note Needs to be called inside a reactive function
#' 
#' @param category Character: data category (e.g. "Carcinoma 2016"); by default,
#' it uses the selected data category
#' 
#' @return Data frame of differential analyses
getDifferentialAnalyses <- function(category = getCategory())
    getGlobal(category, "differentialAnalyses")

#' Get the filtered table of differential analyses of a data category
#' @note Needs to be called inside a reactive function
#' 
#' @param category Character: data category (e.g. "Carcinoma 2016"); by default,
#' it uses the selected data category
#' 
#' @return Filtered data frame of differential analyses
getDifferentialAnalysesFiltered <- function(category = getCategory())
    getGlobal(category, "differentialAnalysesFiltered")

#' Get highlighted events from differential analyses of a data category
#' @note Needs to be called inside a reactive function
#' 
#' @param category Character: data category (e.g. "Carcinoma 2016"); by default,
#' it uses the selected data category
#' 
#' @return Integer of indexes relative to a table of differential analyses
getDifferentialAnalysesHighlightedEvents <- function(category = getCategory())
    getGlobal(category, "differentialAnalysesHighlighted")

#' Get plot coordinates for zooming from differential analyses of a data
#' category
#' @note Needs to be called inside a reactive function
#' 
#' @param category Character: data category (e.g. "Carcinoma 2016"); by default,
#' it uses the selected data category
#' 
#' @return Integer of X and Y axes coordinates
getDifferentialAnalysesZoom <- function(category = getCategory())
    getGlobal(category, "differentialAnalysesZoom")

#' Get selected points in the differential analysis table of a data category
#' @note Needs to be called inside a reactive function
#' 
#' @param category Character: data category (e.g. "Carcinoma 2016"); by default,
#' it uses the selected data category
#' 
#' @return Integer containing index of selected points
getDifferentialAnalysesSelected <- function(category = getCategory())
    getGlobal(category, "differentialAnalysesSelected")

#' Get the table of differential analyses' survival data of a data category
#' @note Needs to be called inside a reactive function
#' 
#' @param category Character: data category (e.g. "Carcinoma 2016"); by default,
#' it uses the selected data category
#' 
#' @return Data frame of differential analyses' survival data
getDifferentialAnalysesSurvival <- function(category = getCategory())
    getGlobal(category, "diffAnalysesSurv")

#' Get the species of a data category
#' @note Needs to be called inside a reactive function
#' 
#' @param category Character: data category (e.g. "Carcinoma 2016"); by default,
#' it uses the selected data category
#' 
#' @return Character value with the species
getSpecies <- function(category = getCategory())
    getGlobal(category, "species")

#' Get the assembly version of a data category
#' @note Needs to be called inside a reactive function
#' 
#' @param category Character: data category (e.g. "Carcinoma 2016"); by default,
#' it uses the selected data category
#' 
#' @return Character value with the assembly version
getAssemblyVersion <- function(category = getCategory())
    getGlobal(category, "assemblyVersion")

#' Get groups from a given data type
#' @note Needs to be called inside a reactive function
#' 
#' @param dataset Character: data set (e.g. "Clinical data")
#' @param category Character: data category (e.g. "Carcinoma 2016"); by default,
#' it uses the selected data category
#' @param complete Boolean: return all the information on groups (TRUE) or just 
#' the group names and respective indexes (FALSE)? FALSE by default
#' @param samples Boolean: show groups by samples (TRUE) or patients (FALSE)?
#' FALSE by default
#' 
#' @return Matrix with groups of a given dataset
getGroupsFrom <- function(dataset, category = getCategory(), complete=FALSE,
                          samples=FALSE) {
    groups <- getGlobal(category, dataset, "groups")
    
    # Return all data if requested
    if (complete) return(groups)
    
    if (samples)
        col <- "Samples"
    else
        col <- "Patients"
    
    # Check if data of interest is available
    if (!col %in% colnames(groups)) return(NULL)
    
    # If available, return data of interest
    g <- groups[ , col, drop=TRUE]
    if (length(g) == 1) names(g) <- rownames(groups)
    return(g)
}

#' Get clinical matches from a given data type
#' @note Needs to be called inside a reactive function
#' 
#' @param dataset Character: data set (e.g. "Junction quantification")
#' @param category Character: data category (e.g. "Carcinoma 2016"); by default,
#' it uses the selected data category
#' 
#' @return Integer with clinical matches to a given dataset
getClinicalMatchFrom <- function(dataset, category = getCategory())
    getGlobal(category, dataset, "clinicalMatch")

#' Get the URL links to download
#' @note Needs to be called inside a reactive function
#' 
#' @return Character vector with URLs to download
getURLtoDownload <- function()
    getGlobal("URLtoDownload")

#' Get principal component analysis based on inclusion levels
#' @note Needs to be called inside a reactive function
#' 
#' @param category Character: data category (e.g. "Carcinoma 2016"); by default,
#' it uses the selected data category
#' 
#' @return \code{prcomp} object (PCA) of inclusion levels
getInclusionLevelsPCA <- function(category = getCategory())
    getGlobal(category, "inclusionLevelsPCA")

#' Set element as globally accessible
#' @details Set element inside the global variable
#' @note Needs to be called inside a reactive function
#' 
#' @param ... Arguments to identify a variable
#' @param value Any value to attribute to an element
#' @param sep Character to separate identifier
#' 
#' @return NULL (this function is used to modify the Shiny session's state)
setGlobal <- function(..., value, sep="_") {
    sharedData[[paste(..., sep=sep)]] <- value
}

#' Set data of the global data
#' @note Needs to be called inside a reactive function
#' @param data Data frame or matrix to set as data
#' @return NULL (this function is used to modify the Shiny session's state)
setData <- function(data) setGlobal("data", value=data)

#' Set if history browsing is automatic
#' @note Needs to be called inside a reactive function
#' @param param Boolean: is navigation of browser history automatic?
#' @return NULL (this function is used to modify the Shiny session's state)
setAutoNavigation <- function(param) setGlobal("autoNavigation", value=param)

#' Set number of cores
#' @param cores Character: number of cores
#' @note Needs to be called inside a reactive function
#' @return NULL (this function is used to modify the Shiny session's state)
setCores <- function(cores) setGlobal("cores", value=cores)

#' Set number of significant digits
#' @param significant Character: number of significant digits
#' @note Needs to be called inside a reactive function
#' @return NULL (this function is used to modify the Shiny session's state)
setSignificant <- function(significant) setGlobal("significant", value=significant)

#' Set number of decimal places
#' @param precision Numeric: number of decimal places
#' @return NULL (this function is used to modify the Shiny session's state)
#' @note Needs to be called inside a reactive function
setPrecision <- function(precision) setGlobal("precision", value=precision)

#' Set event
#' @param event Character: event
#' @note Needs to be called inside a reactive function
#' @return NULL (this function is used to modify the Shiny session's state)
setEvent <- function(event) setGlobal("event", value=event)

#' Set data category
#' @param category Character: data category
#' @note Needs to be called inside a reactive function
#' @return NULL (this function is used to modify the Shiny session's state)
setCategory <- function(category) setGlobal("category", value=category)

#' Set active dataset
#' @param dataset Character: dataset
#' @note Needs to be called inside a reactive function
#' @return NULL (this function is used to modify the Shiny session's state)
setActiveDataset <- function(dataset) setGlobal("activeDataset", value=dataset)

#' Set inclusion levels for a given data category
#' @note Needs to be called inside a reactive function
#' 
#' @param value Data frame or matrix: inclusion levels
#' @param category Character: data category (e.g. "Carcinoma 2016"); by default,
#' it uses the selected data category
#' @return NULL (this function is used to modify the Shiny session's state)
setInclusionLevels <- function(value, category = getCategory())
    sharedData$data[[category]][["Inclusion levels"]] <- value

#' Set sample information for a given data category
#' @note Needs to be called inside a reactive function
#' 
#' @param value Data frame or matrix: sample information
#' @param category Character: data category (e.g. "Carcinoma 2016"); by default,
#' it uses the selected data category
#' @return NULL (this function is used to modify the Shiny session's state)
setSampleInfo <- function(value, category = getCategory())
    sharedData$data[[category]][["Sample metadata"]] <- value

#' Set groups from a given data type
#' @note Needs to be called inside a reactive function
#' 
#' @param dataset Character: data set (e.g. "Clinical data")
#' @param groups Matrix: groups of dataset
#' @param category Character: data category (e.g. "Carcinoma 2016"); by default,
#' it uses the selected data category
#' @return NULL (this function is used to modify the Shiny session's state)
setGroupsFrom <- function(dataset, groups, category = getCategory())
    setGlobal(category, dataset, "groups", value=groups)

#' Set the identifier of patients for a data category
#' @note Needs to be called inside a reactive function
#' 
#' @param value Character: identifier of patients
#' @param category Character: data category (e.g. "Carcinoma 2016"); by default,
#' it uses the selected data category
#' @return NULL (this function is used to modify the Shiny session's state)
setPatientId <- function(value, category = getCategory())
    setGlobal(category, "patients", value=value)

#' Set the identifier of samples for a data category
#' @note Needs to be called inside a reactive function
#' 
#' @param value Character: identifier of samples
#' @param category Character: data category (e.g. "Carcinoma 2016"); by default,
#' it uses the selected data category
#' @return NULL (this function is used to modify the Shiny session's state)
setSampleId <- function(value, category = getCategory())
    setGlobal(category, "samples", value=value)

#' Set the table of differential analyses of a data category
#' @note Needs to be called inside a reactive function
#' 
#' @param table Character: differential analyses table
#' @param category Character: data category (e.g. "Carcinoma 2016"); by default,
#' it uses the selected data category
#' @return NULL (this function is used to modify the Shiny session's state)
setDifferentialAnalyses <- function(table, category = getCategory())
    setGlobal(category, "differentialAnalyses", value=table)

#' Set the filtered table of differential analyses of a data category
#' @note Needs to be called inside a reactive function
#' 
#' @param table Character: filtered differential analyses table
#' @param category Character: data category (e.g. "Carcinoma 2016"); by default,
#' it uses the selected data category
#' @return NULL (this function is used to modify the Shiny session's state)
setDifferentialAnalysesFiltered <- function(table, category = getCategory())
    setGlobal(category, "differentialAnalysesFiltered", value=table)

#' Set highlighted events from differential analyses of a data category
#' @note Needs to be called inside a reactive function
#' 
#' @param events Integer: indexes relative to a table of differential analyses
#' @param category Character: data category (e.g. "Carcinoma 2016"); by default,
#' it uses the selected data category
#' 
#' @return NULL (this function is used to modify the Shiny session's state)
setDifferentialAnalysesHighlightedEvents <- function(events, 
                                                     category = getCategory())
    setGlobal(category, "differentialAnalysesHighlighted", value=events)

#' Set plot coordinates for zooming from differential analyses of a data
#' category
#' @note Needs to be called inside a reactive function
#' 
#' @param zoom Integer: X and Y coordinates
#' @param category Character: data category (e.g. "Carcinoma 2016"); by default,
#' it uses the selected data category
#' 
#' @return NULL (this function is used to modify the Shiny session's state)
setDifferentialAnalysesZoom <- function(zoom, category=getCategory())
    setGlobal(category, "differentialAnalysesZoom", value=zoom)

#' Set selected points in the differential analysis table of a data category
#' @note Needs to be called inside a reactive function
#' 
#' @param points Integer: index of selected points
#' @param category Character: data category (e.g. "Carcinoma 2016"); by default,
#' it uses the selected data category
#' 
#' @return NULL (this function is used to modify the Shiny session's state)
setDifferentialAnalysesSelected <- function(points, category=getCategory())
    setGlobal(category, "differentialAnalysesSelected", value=points)

#' Set the table of differential analyses' survival data of a data category
#' @note Needs to be called inside a reactive function
#' 
#' @param table Character: differential analyses' survival data
#' @param category Character: data category (e.g. "Carcinoma 2016"); by default,
#' it uses the selected data category
#' @return NULL (this function is used to modify the Shiny session's state)
setDifferentialAnalysesSurvival <- function(table, category = getCategory())
    setGlobal(category, "diffAnalysesSurv", value=table)

#' Set the species of a data category
#' @note Needs to be called inside a reactive function
#' 
#' @param value Character: species
#' @param category Character: data category (e.g. "Carcinoma 2016"); by default,
#' it uses the selected data category
#' @return NULL (this function is used to modify the Shiny session's state)
setSpecies <- function(value, category = getCategory())
    setGlobal(category, "species", value=value)

#' Set the assembly version of a data category
#' @note Needs to be called inside a reactive function
#' 
#' @param value Character: assembly version
#' @param category Character: data category (e.g. "Carcinoma 2016"); by default,
#' it uses the selected data category
#' @return NULL (this function is used to modify the Shiny session's state)
setAssemblyVersion <- function(value, category = getCategory())
    setGlobal(category, "assemblyVersion", value=value)

#' Set clinical matches from a given data type
#' @note Needs to be called inside a reactive function
#' 
#' @param dataset Character: data set (e.g. "Clinical data")
#' @param matches Vector of integers: clinical matches of dataset
#' @param category Character: data category (e.g. "Carcinoma 2016"); by default,
#' it uses the selected data category
#' @return NULL (this function is used to modify the Shiny session's state)
setClinicalMatchFrom <- function(dataset, matches, category = getCategory())
    setGlobal(category, dataset, "clinicalMatch", value=matches)

#' Set URL links to download
#' @note Needs to be called inside a reactive function
#' 
#' @param url Character: URL links to download
#' 
#' @return NULL (this function is used to modify the Shiny session's state)
setURLtoDownload <- function(url)
    setGlobal("URLtoDownload", value=url)

#' Get principal component analysis based on inclusion levels
#' @note Needs to be called inside a reactive function
#' 
#' @param pca \code{prcomp} object (PCA) of inclusion levels
#' @param category Character: data category (e.g. "Carcinoma 2016"); by default,
#' it uses the selected data category
#' 
#' @return NULL (this function is used to modify the Shiny session's state)
setInclusionLevelsPCA <- function(pca, category=getCategory())
    setGlobal(category, "inclusionLevelsPCA", value=pca)
