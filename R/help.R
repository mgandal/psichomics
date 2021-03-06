#' User interface of the help menu
#' 
#' @param id Character: identifier
#' @param tab Function to create tabs
#' 
#' @importFrom shiny textOutput
#' 
#' @return HTML elements
helpUI <- function(id, tab) {
    ns <- NS(id)
    
    # if (requireNamespace("parallel", quietly = TRUE)) {
    #     cores <- parallel::detectCores()
    #     coresInput <- tagList(
    #         sliderInput(ns("cores"), h4("Number of cores"), value=1, min=1, 
    #                     step=1, max=cores, width="auto", post=" core(s)"),
    #         helpText("A total of", cores, "cores were detected.")
    #     )
    # } else {
    #     coresInput <- numericInput(ns("cores"), h4("Number of cores"), value=1,
    #                                min=1, step=1, width="auto")
    # }
    
    credits <- c("Lina Gallego", "Marie Bordone", "Mariana Ferreira",
                 "Teresa Maia", "Carolina Leote", "Juan Carlos Verjan",
                 "Bernardo Almeida")
    credits <- lapply(credits, tags$li, class="list-group-item")
    
    immLink <- "http://imm.medicina.ulisboa.pt/group/compbio/team.html"
    guiLink <- "http://rpubs.com/nuno-agostinho/psichomics-tutorial-visual"
    cliLink <- "http://rpubs.com/nuno-agostinho/psichomics-cli-tutorial"
    bioconductorSupportLink <- "https://support.bioconductor.org/t/psichomics/"
    githubIssues <- "https://github.com/nuno-agostinho/psichomics/issues/new"
    
    tab(title="Help", icon="question",
        h2("Settings", style="margin-top: 0;"),
        fluidRow(
            # column(4, coresInput),
            column(4,
                   sliderInput(ns("precision"), h4("Numeric precision"),
                               value=3, min=0, max=10, step=1, width="auto",
                               post=" decimal(s)"),
                   textOutput(ns("precisionExample")),
                   helpText("Only applies to new calculations.")),
            column(4,
                   sliderInput(ns("significant"), h4("Significant digits"),
                               value=3, min=0, max=10, step=1, width="auto",
                               post=" digit(s)"),
                   textOutput(ns("significantExample")),
                   helpText("Only applies to new calculations."))),
        h2("Support"),
        fluidRow(
            column(
                4, div(
                    class="panel", class="panel-default",
                    div(class="panel-heading", 
                        icon("file-text"), tags$b("Tutorials")),
                    tags$ul(
                        class="list-group",
                        tags$li(class="list-group-item",
                                tags$a(
                                    href=guiLink,
                                    target="_blank",
                                    "Visual interface tutorial")),
                        tags$li(class="list-group-item",
                                tags$a(
                                    href=cliLink,
                                    target="_blank",
                                    "Command-line interface tutorial")))),
                div(
                    class="panel", class="panel-default",
                    div(class="panel-heading",
                        icon("comments"), tags$b("Feedback")),
                    div(class="panel-body",
                        "From questions to suggestions, all feedback is",
                        "welcome."),
                    tags$ul(
                        class="list-group",
                        tags$li(class="list-group-item",
                                tags$a(
                                    href=bioconductorSupportLink,
                                    target="_blank",
                                    "Questions and general support")),
                        tags$li(class="list-group-item",
                                tags$a(
                                    href=githubIssues,
                                    target="_blank",
                                    "Suggestions and bug reports"))))),
            column(
                4, div(
                    class="panel", class="panel-default",
                    div(class="panel-heading",
                        icon("info-circle"), tags$b("About")),
                    div(class="panel-body",
                        "psichomics is an interactive R package for",
                        "integrative alternative splicing analyses using",
                        "data from",
                        tags$a(href="https://cancergenome.nih.gov",
                               target="_blank",
                               "The Cancer Genome Atlas"),
                        "and from the",
                        tags$a(href="https://www.gtexportal.org/home/",
                               target="_blank",
                               "Genotype-Tissue Expression"),
                        "project."),
                    tags$ul(
                        class="list-group",
                        tags$li(class="list-group-item",
                                tags$b("Developer:"), tags$a(
                                    href="mailto:nunodanielagostinho@gmail.com",
                                    target="_blank",
                                    "Nuno Saraiva-Agostinho",
                                    icon("envelope-o"))),
                        tags$li(class="list-group-item",
                                tags$b("Supervisor:"), "Nuno Barbosa-Morais"),
                        tags$li(class="list-group-item",
                                tags$b("Host lab:"),
                                tags$a(
                                    href=immLink,
                                    target="_blank",
                                    "Computational Biology lab")),
                        tags$li(class="list-group-item",
                                tags$b("Institution:"),
                                tags$a(
                                    href="http://imm.medicina.ulisboa.pt",
                                    target="_blank",
                                    "Instituto de Medicina Molecular")),
                        tags$li(class="list-group-item",
                                tags$small(class="help-block",
                                           style="text-align: right;",
                                           style="margin: 0;",
                                           "2015-2017"))))),
            column(
                4, div(
                    class="panel", class="panel-default",
                    div(class="panel-heading",
                        icon("life-ring"), tags$b("Acknowledgments")),
                    div(class="panel-body",
                        "This work would not be possible without the support",
                        "of current and former members of Nuno Morais lab.",
                        "Thank you all for your help."),
                    do.call(tags$ul, c(credits, list(class="list-group")))))))
}

#' Server logic of the help menu
#' 
#' @param session Shiny session
#' @param input Shiny input
#' @param output Shiny output
#' 
#' @importFrom shiny observe renderText
#' @return NULL (this function is used to modify the Shiny session's state)
helpServer <- function(input, output, session) {
    # observe(setCores(input$cores))
    observe({
        setPrecision(input$precision)
        output$precisionExample <- renderText(
            paste("Example:",
                  formatC(283.5837243243332313139838387437323823823829,
                          digits=getPrecision(), format="f")))
    })
    
    observe({
        setSignificant(input$significant)
        output$significantExample <- renderText(
            paste("Example:", 
                  formatC(0.000005849839043444982905434543482092830943,
                          getSignificant(), format="g")))
    })
}

attr(helpUI, "loader") <- "app"
attr(helpServer, "loader") <- "app"