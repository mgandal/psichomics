## TODO(NunoA): project either individuals (as default) or events
## TODO(NunoA): add histogram in/above percentage of NAs per row to remove
## TODO(NunoA): add brushing capabilities (brush function from Shiny? only
## rectangle selection available?)
## TODO(NunoA): logarithmic values
## TODO(NunoA): BoxCox transformation

## TODO(NunoA): create clusters and use those clusters as groups of data
##
##  km <- kmeans(scores, centers = 7, nstart = 5)
##  ggdata <- data.frame(scores, Cluster=km$cluster, Species=df$Species)
##  ggplot(ggdata) +
##      geom_point(aes(x=PC1, y=PC2, color=factor(Cluster)), size=5, shape=20) +
##      stat_ellipse(aes(x=PC1,y=PC2,fill=factor(Cluster)),
##          geom="polygon", level=0.95, alpha=0.2) +
##      guides(color=guide_legend("Cluster"),fill=guide_legend("Cluster"))
## 
## Source:
## http://stackoverflow.com/questions/20260434/test-significance-of-clusters-on-a-pca-plot

# The name used for the plot must be unique
getMatchingRowNames <- function(selected, clinicalGroups, clinicalMatches) {
    # Get selected groups from clinical data
    rows <- clinicalGroups[selected, "Rows"]
    
    # Get names of the matching rows with the clinical data
    ns <- names(clinicalMatches[clinicalMatches %in% unlist(rows)])
    ns <- toupper(unique(ns))
    return(ns)
}

#' @importFrom stats prcomp
#' @importFrom miscTools rowMedians
psiPCA <- function(psi, center = TRUE, scale. = FALSE, naTolerance = 30) {
    # Get individuals (rows) with less than a given percentage of NAs
    nas <- apply(psi, 1, function(row) sum(is.na(row)))
    # hist(nas/ncol(psi)*100)
    psi <- psi[nas/ncol(psi)*100 <= naTolerance, , drop = FALSE]
    if (nrow(psi) == 0) return(NULL)
    
    # Replace NAs with the medians for each individual (row)
    medians <- rowMedians(psi, na.rm=TRUE)
    nas <- apply(psi, 1, function(row) sum(is.na(row)))
    psi[is.na(psi)] <- rep(medians, nas)
    
    # Perform principal component analysis on resulting data
    pca <- prcomp(psi, center = center, scale. = scale.)
    # PCA is useless if done with only one point
    if (nrow(pca$x) == 1) return(NULL)
    return(pca)
}

#' @importFrom highcharter highchartOutput
pcaUI <- function(id) {
    ns <- NS(id)
    tagList(
        uiOutput(ns("modal")),
        sidebarPanel(
            checkboxGroupInput(ns("preprocess"), "Preprocessing",
                               c("Center values" = "center",
                                 "Scale values" = "scale"),
                               selected = c("center")),
            sliderInput(ns("naTolerance"), "Percentage of NAs per individual to tolerate",
                        min = 0, max=100, value=30, post="%"),
            selectGroupsUI(ns("dataGroups"), "Clinical groups to perform PCA"),
            actionButton(ns("editGroups"), "Edit groups"),
            actionButton(ns("calculate"), class = "btn-primary", "Calculate PCA"),
            uiOutput(ns("selectPC"))
        ), mainPanel(
            highchartOutput(ns("scatterplot"))
        )
    )
}

#' Interface and plots to help selecting principal components
#' @param ns Shiny namespace function
#' @param output Shiny output
selectPC <- function(ns, output, perc) {
    output$selectPC <- renderUI({
        label <- sprintf("%s (%s%% explained variance)", 
                         names(perc), roundDigits(perc * 100))
        choices <- setNames(names(perc), label)
        groups <- getGroupsFrom("Clinical data")
        
        tagList(
            hr(),
            selectizeInput(ns("pcX"), "Choose X axis", choices = choices),
            selectizeInput(ns("pcY"), "Choose Y axis", choices = choices,
                           selected = choices[[2]]),
            selectGroupsUI(ns("colourGroups"),
                           "Clinical groups to colour the PCA"),
            checkboxGroupInput(ns("plotShow"), "Show in plot",
                               c("Individuals", "Loadings"),
                               selected = c("Individuals")),
            actionButton(ns("showVariancePlot"), "Show variance plot"),
            actionButton(ns("plot"), class = "btn-primary", "Plot PCA")
        )
    })
}

#' Render the explained variance plot
#' @param ouput Shiny output
#' @param pca PCA values
#' 
#' @importFrom highcharter highchart hc_chart hc_title hc_add_series 
#' hc_plotOptions hc_xAxis hc_yAxis hc_legend hc_tooltip hc_exporting
plotVariance <- function(output, pca) {
    output$variancePlot <- renderHighchart({
        sdevSq <- pca$sdev ^ 2
        
        highchart() %>%
            hc_chart(zoomType = "xy", backgroundColor = NULL) %>%
            hc_title(text = paste("Explained variance by each",
                                  "Principal Component (PC)")) %>%
            hc_add_series(name = "PCs", data = sdevSq,
                          type = "waterfall") %>%
            hc_plotOptions(series = list(dataLabels = list(
                align = "center",
                verticalAlign = "top",
                enabled = TRUE,
                formatter = JS(
                    "function() {",
                    "var total = ", sum(sdevSq), ";",
                    "var perc = (this.y/total) * 100;",
                    "return (Highcharts.numberFormat(this.y) +'<br/>'+",
                    "Highcharts.numberFormat(perc) + '%')}")))) %>%
            hc_xAxis(categories = colnames(pca[["x"]]), 
                     crosshair = TRUE) %>%
            hc_yAxis(title = list(text = "Explained variance")) %>%
            hc_legend(enabled = FALSE) %>%
            hc_tooltip(pointFormat = 
                           '{point.name} {point.y:.2f} {point.perc}') %>%
            hc_exporting(enabled = TRUE,
                         buttons = list(contextButton = list(
                             text = "Export", y = -50,
                             verticalAlign = "bottom",
                             theme = list(fill = NULL))))
    })
}

#' @importFrom highcharter %>% hc_chart hc_xAxis hc_yAxis hc_tooltip
pcaServer <- function(input, output, session) {
    ns <- session$ns

    selectGroupsServer(session, "dataGroups", getClinicalData(),
                       "Clinical data")
    selectGroupsServer(session, "colourGroups", getClinicalData(),
                       "Clinical data")
    
    # Perform principal component analysis (PCA)
    observeEvent(input$calculate, {
        psi <- isolate(getInclusionLevels())
        
        if (is.null(psi)) {
            errorModal(session, "Inclusion levels missing",
                       "Insert or calculate exon/intron inclusion levels.")
        } else {
            # Subset data by the selected clinical groups
            selected <- isolate(input$dataGroups)
            if (!is.null(selected)) {
                clinical <- isolate(getGroupsFrom("Clinical data"))
                match <- getClinicalMatchFrom("Inclusion levels")
                ns <- getMatchingRowNames(selected, clinical, match)
                psi <- psi[ , ns]
            }
            
            # Raise error if data has no rows
            if (nrow(psi) == 0)
                errorModal(session, "No data!", paste(
                    "Calculation returned nothing. Check if everything is as",
                    "expected and try again."))
            
            # Transpose the data to have individuals as rows
            psi <- t(psi)
            
            # Perform principal component analysis (PCA) on the subset data
            isolate({
                preprocess <- input$preprocess
                naTolerance <- input$naTolerance
            })
            
            pca <- psiPCA(psi, naTolerance = naTolerance,
                          center = "center" %in% preprocess,
                          scale. = "scale" %in% preprocess)
            if (is.null(pca)) {
                errorModal(session, "No individuals to plot PCA", 
                           "Try increasing the tolerance of NAs per individual.")
            }
            sharedData$inclusionLevelsPCA <- pca
        }
    })
    
    # Show variance plot
    observeEvent(input$showVariancePlot, {
        infoModal(session, "Variance plot", highchartOutput(ns("variancePlot")),
                  size = "large")
    })
    
    observe({
        pca <- sharedData$inclusionLevelsPCA
        if (is.null(pca)) return(NULL)
        
        imp <- summary(pca)$importance[2, ]
        perc <- as.numeric(imp)
        names(perc) <- names(imp)
        
        # Interface and plots to help select principal components
        selectPC(ns, output, perc)
        
        # Plot the explained variance plot
        plotVariance(output, pca)
        
        # Plot the principal component analysis
        observeEvent(input$plot, {
            isolate({
                xAxis <- input$pcX
                yAxis <- input$pcY
                selected <- input$colourGroups
                show <- input$plotShow
            })
            
            output$scatterplot <- renderHighchart({
                if (!is.null(xAxis) & !is.null(yAxis)) {
                    label <- sprintf("%s (%s%% explained variance)", 
                                     names(perc[c(xAxis, yAxis)]), 
                                     roundDigits(perc[c(xAxis, yAxis)]*100))
                    
                    hc <- highchart() %>%
                        hc_chart(zoomType = "xy") %>%
                        hc_xAxis(title = list(text = label[1])) %>%
                        hc_yAxis(title = list(text = label[2])) %>%
                        hc_tooltip(pointFormat = "{point.sample}")
                    
                    if ("Individuals" %in% show) {
                        df <- data.frame(pca$x)
                        if (is.null(selected)) {
                            hc <- hc %>% hc_scatter(df[[xAxis]], df[[yAxis]],
                                                    sample = rownames(df))
                        } else {
                            # Subset data by the selected clinical groups
                            clinical <- getGroupsFrom("Clinical data")
                            match <- getClinicalMatchFrom("Inclusion levels")
                            
                            for (groupName in selected) {
                                rows <- getMatchingRowNames(groupName, clinical,
                                                            match)
                                rows <- rows[rows %in% rownames(df)]
                                hc <- hc %>%
                                    hc_scatter(df[rows, xAxis],
                                               df[rows, yAxis],
                                               name = groupName,
                                               sample = rownames(df[rows, ]),
                                               showInLegend = TRUE)
                            }
                        }
                    }
                    if ("Loadings" %in% show) {
                        m <- data.frame(pca$rotation)
                        # For loadings, add series (don't add to legend)
                        hc <- hc %>% hc_scatter(m[[xAxis]], m[[yAxis]])
                    }
                    return(hc)
                }
            })
        })
    })
}

attr(pcaUI, "loader") <- "analysis"
attr(pcaUI, "name") <- "Principal Component Analysis (PCA)"
attr(pcaServer, "loader") <- "analysis"