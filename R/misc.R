# Glue URL
#' Title
#'
#' @param url URL end point
#' @param api Riot API
#' @param dry_run If True return url
#'
#' @export
get_url = function(url, api, dry_run = FALSE) {
  url <- httr::modify_url(
    url = glue::glue(url),
    query = list(api_key = api)
  ) %>%
    stringr::str_replace_all(" ", "+")

  if (dry_run) {
    return(url)
  } else {
    data <- httr::GET(url)
  }

  if (data$status_code != 200) {
    msg <- httr::content(data)$status$message
    status_code <- data$status_code

    output <- glue::glue("GET error: {msg} (Status Code: {status_code}, URL: {url})")
    return(output)
  } else {
    return(data)
  }
}

#' Route TFT region
#'
#' @param region region
#'
#' @export
route_tft <- function(region) {
  region <- tolower(region)
  if (stringr::str_detect(region, "(oc)|(na)|(br)|(la)|(las)")) {
    output <- "americas"
  } else if (stringr::str_detect(region, "(kr)|(jp)")) {
    output <- "asia"
  } else if (stringr::str_detect(region, "(eu)|(tr)|(ru)")) {
    output <- "europe"
  } else {
    stop(glue::glue("{region} not defined"))
  }

  return(output)
}

#' Check tier input
#'
#' @param tier Input for tier
#'
#' @export
check_tier <- function(tier) {
  tier <- toupper(tier)

  if (tier == "DIAMOND" || tier == "PLATINUM" || tier == "GOLD" ||
      tier == "SILVER" || tier == "BRONZE" || tier == "IRON") {
    return(tier)
  } else {
    warning(glue::glue("Incorrect tier, got {tier},
                       expected: DIAMOND, PLATINUM, GOLD, SILVER, BRONZE, IRON"))
  }
}

#' Check division input
#'
#' @param division Input for division
#'
#' @export
check_division <- function(division) {
  # If input is numeric then do conversion
  if(!is.character(division)) {
    division <- switch(
      division,
      "I",
      "II",
      "III",
      "IV"
    )

    # If input is out of range then it'll return NULL
    if (is.null(division)) {
      warning("Incorrect input")
    }
  }

  # Check if input is one of the 4 division
  if (division == "I" || division == "II" ||
      division == "III"|| division == "IV") {
    return(division)
  } else {
    warning("Incorrect input")
  }

}

#' Check queue input
#'
#' @param queue Queue name, acceptable input: RANKED_SOLO_5x5, RANKED_FLEX_SR, RANKED_FLEX_TT
#'
#' @export
check_queue <- function(queue) {
  if (queue == "RANKED_SOLO_5x5" || queue == "RANKED_FLEX_SR" || queue == "RANKED_FLEX_TT") {
    return(queue)
  } else {
    warning(glue::glue("Incorrect queue name, got: {queue}"))
  }
}


#' Check if api key is valid
#'
#' @param api Riot API
#' @param game Game to test API on. Note development key will work on any game
#' but production key might be limited your focused game. Acceptable input:
#' tft, league, any
#'
#' @export
check_api <- function(api, game = "any") {
  game <- tolower(game)

  if (game == "league") {
    data <- httr::GET(glue::glue("https://oc1.api.riotgames.com/lol/status/v3/shard-data?api_key={api}"))
  } else if (game == "tft") {
    data <- httr::GET(glue::glue("https://oc1.api.riotgames.com/tft/league/v1/challenger?api_key={api}"))
  } else {
    data <- httr::GET(glue::glue("https://oc1.api.riotgames.com/lol/platform/v3/champion-rotations?api_key={api}"))
  }

  if (data$status_code != 200) {
    return(FALSE)
  } else {
    return(TRUE)
  }
}

#' Get user's id
#'
#' @param name User name
#' @param api Riot API
#' @param region User's region
#' @param game Gamemode. Acceptable input: tft, league, any. Default to any
#'
#' @export
get_user_id <- function(name, region, api, game = "any") {
  # Make sure API is valid
  if(!check_api(api, game)) {
    stop("Invalid API")
  }

  # Get data base on input
  if (game == "league" | game == "any") {
    data <- httr::GET(glue::glue("https://{region}.api.riotgames.com/lol/summoner/v4/summoners/by-name/{name}?api_key={api}"))
  } else if (game == "tft") {
    data <- httr::GET(glue::glue("https://{region}.api.riotgames.com/tft/summoner/summoners/by-name/{name}?api_key={api}"))
  } else {
    stop(glue::glue("invalid game input, got: {game}"))
  }

  # Sanity check
  if (data$status_code != 200) {stop(glue::glue("Cannot access data, error: {content(data)}"))}

  return(httr::content(data))
}
