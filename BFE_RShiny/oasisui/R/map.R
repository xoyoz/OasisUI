#' Create Plain Map
#'
#' @rdname createPlainMap
#'
#' @description Creates a plain map using leaflet.
#'
#' @param df df to plot as map
#' @param session Current session.
#' @param paramID Chosen parameter ID.
#' @param step Only important if user is in Validation Map. NULL by default.
#'
#' @return Leaflet map.
#'
#' @importFrom leaflet leaflet
#' @importFrom leaflet addTiles
#' @importFrom leaflet addMarkers
#' @importFrom leaflet markerClusterOptions
#' @importFrom leaflet.extras addFullscreenControl
#'
#' @export
createPlainMap <- function(df, session, paramID, step = NULL) {

  df <- build_marker_data(df, session, paramID, step)

  # Create custom icons
  icon_map <- awesomeIcons(
    icon = 'map-marker-alt',
    library = 'fa',
    iconColor = 'green',
    markerColor = 'blue'
  )

  leaflet(df) %>%
    addTiles() %>%
    addMarkers(lng = ~longitude,
               lat = ~latitude,
               icon = icon_map,
               clusterOptions = markerClusterOptions(maxClusterRadius = 50),
               popup = ~popup) %>% # make map full screen
    addFullscreenControl(pseudoFullscreen = TRUE)
}


#' build_marker_data
#'
#' @rdname build_marker_data
#'
#' @description Builds markers data to be used in a map rendered with leaflet.
#'
#' @param data dataframe containing location id and coordinates.
#' @param session Current session.
#' @param paramID Chosen parameter ID.
#' @param step Only important if user is in Validation Map. NULL by default.
#'
#' @return dataframe with popup information under "popup".
#'
#' @export
build_marker_data <- function(data, session, paramID, step = NULL) {
  names(data) <- tolower(names(data))

  # extract error messages in case status is "Fail"
  error_msg <- .keys_errors_msg(data, session, paramID)

  # In case streetaddress and postalcode are not entries of the data frame, create vector of NAs
  if (is.null(data$streetaddress)) {
    data$streetaddress <- rep_len(NA, nrow(data))
  }
  if (is.null(data$postalcode)) {
    data$postalcode <- rep_len(NA, nrow(data))
  }

  # sum over all TIVs
  tiv <- data.frame(total = rep_len(0, nrow(data)))
  tiv_var <- 0
  for (i in grep("tiv", names(data))) {
    if(length(i) > 0 && !is.na(data[[i]])) {
      tiv_var <- tiv_var + data[[i]]
      tiv$total <- add_commas(tiv_var)
    }
  }

  # Popup data, must be a character vector of html code
  if (!is.null(step)) {
    # Include error message only if validation map
    data$popup <- mapply(
      function(id, total, streetaddress, postalcode, error_msg) {
        as.character(div(
          strong("Location ID: "), id,
          br(), strong("TIV: "), total,
          br(), strong("Street Address: "), streetaddress,
          br(), strong("Postal code: "), postalcode,
          br(), strong("Error message: "), error_msg
        ))
      },
      data$locnumber, tiv$total[[1]], data$streetaddress, data$postalcode, error_msg)
  } else {
    data$popup <- mapply(
      function(id, total, streetaddress, postalcode) {
        as.character(div(
          strong("Location ID: "), id,
          br(), strong("TIV: "), total,
          br(), strong("Street Address: "), streetaddress,
          br(), strong("Postal code: "), postalcode
        ))
      },
      data$locnumber, tiv$total[[1]], data$streetaddress, data$postalcode)
  }
  data
}


# Extract error messages
.keys_errors_msg <- function(data, session, paramID) {
  keys_errors <- session$userData$data_hub$get_ana_dataset_content(id = paramID,
                                                                   dataset_identifier = "keys-errors.csv",
                                                                   type = "input")
  error_msg <- data.frame(message = 1:nrow(data))
  if (!is.null(keys_errors)) {
    for (i in seq(1, nrow(data))) {
      if (length(keys_errors$LocID[which(keys_errors$LocID == i)]) == 0) {
        error_msg$message[i] <- NA
      } else {
        errors_list <- as.list(keys_errors$Message[which(keys_errors$LocID == i)])
        errors_paste <- paste(lapply(seq(1, length(errors_list)), function (x) {
          paste(keys_errors$PerilID[x], ":", errors_list[x], "/")
        }), collapse = " ")
        error_msg$message[i] <- errors_paste
      }
    }
  } else {
    error_msg$message <- rep_len(NA, nrow(data))
  }
  error_msg$message
}

