% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/oasisuiIncrementalPanel.R
\name{oasisuiIncrementalPanel}
\alias{oasisuiIncrementalPanel}
\alias{oasisuiIncrementalPanelUI}
\title{oasisuiIncrementalPanel}
\usage{
oasisuiIncrementalPanel(input, output, session, panels_state,
  new_content_IDs, new_content_fun, ..., new_headings = NULL,
  collapsible = FALSE, show = TRUE)

oasisuiIncrementalPanelUI(id, ..., heading = NULL, footer = NULL,
  status = "default", collapsible = FALSE, show = TRUE,
  removable = TRUE)
}
\arguments{
\item{input, output, session}{Shiny input, output, and session objects.}

\item{panels_state}{State (taken/available) of panels placeholders, a
\code{\link[=reactiveValues]{reactiveValues()}} object with a named scalar logical element for each
panel ID. The state is updated upon addition / removal of panels.}

\item{new_content_IDs}{Named character vector of IDs to be used for the
content of each panel upon its creation. Names match the elements of
\code{panels_state}.}

\item{new_content_fun}{Function used to populate any new panel.}

\item{...}{For the module server function, additional aruments passed to
\code{new_content_fun}. For the module UI function, the elements to include
inside the panel.}

\item{new_headings}{Heading content to be used for each panel upon its
creation, as a named character vector or list. Names match the elements of
\code{panels_state}.}

\item{collapsible}{Logical flag specifying if the panel is collapsible.}

\item{show}{Logical flag specifying if a collapsible panel should be
initially shown as not collapsed.}

\item{id}{Namespace ID for the module.}

\item{heading}{Title for the panel.}

\item{footer}{Footer for the panel.}

\item{status}{Bootstrap status for contextual alternative.}

\item{removable}{Logical flag specifying if the panel can be removed.}
}
\description{
Incremental oasisui panel module, including a button to add
a new panel above.
}
\examples{
if (interactive()) {
  library(shiny)
  n_panels <- 10L
  # Example module
  examplePanelUI <- function(id) {
    ns <- NS(id)
    verticalLayout(
      textInput(ns("txt_in"), label = paste("type something", id)),
      textOutput(ns("txt_out")),
      actionButton(ns("upd"), "Update")
    )
  }
  examplePanel <- function(input, output, session, reset = reactive(FALSE)) {
    txt <- reactiveVal(NULL)
    observe({
      reset()
      txt(NULL)
    })
    observeEvent(input$upd, txt(input$txt_in))
    output$txt_out <- renderText(txt())
    reactive(txt())
  }
  ui <- fluidPage(
    tags$style(HTML('
                    .collapsebtn:after {
                    font-family: "Font Awesome 5 Free"; font-weight: 900; content: "\\\\f068";
                    float: right;
                    }
                    .collapsebtn.collapsed:after {
                    content: "\\\\f31e";
                    }
                    ')),
    titlePanel("Dynamic panels"),
    verticalLayout(
      actionButton("delete_all", "Remove all panels"),
      oasisuiIncrementalPanelUI(
        "start-panel", heading = "Add a new panel",
        collapsible = FALSE, show = FALSE, removable = FALSE
      )
    )
  )
  server <- function(input, output, session) {
    # NOTE that, since we are using server logic to create UI elements, the IDs
    # used for the UI components must include session$ns (relevant for module
    # server functions)
    ns <- session$ns
    panel_IDs <- paste0("extpanel-", seq_len(n_panels))
    # content IDs used for the content module server and UI
    # content modules
    content_IDs <- paste0("content-", seq_len(n_panels))
    all_panels <- callIncrementalPanelModules(
      panel_IDs, "start-panel", content_IDs,
      examplePanelUI,
      headings = lapply(seq_len(n_panels), function(i) {
        oasisuiPanelHeadingOutput(ns(paste0("paneltitle", i)))
      }),
      collapsible = TRUE, show = TRUE,
      ns = ns
    )
    panel_modules <- lapply(seq_len(n_panels), function(i) {
      callModule(examplePanel, content_IDs[i], reactive(all_panels$state[[ns(panel_IDs[i])]]))
    })
    lapply(seq_along(panel_modules), function(i) {
      output[[paste0("paneltitle", i)]] <- renderOasisuiPanelHeading(panel_modules[[i]]())
    })
    observeEvent(input$delete_all, {
      all_panels$remove_all()
    })
  }

  shinyApp(ui = ui, server = server)

}
}
