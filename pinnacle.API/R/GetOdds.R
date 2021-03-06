#' Get Odds
#'
#' @param sportname The sport name for which to retrieve the fixutres
#' @param leagueids integer vector of leagueids.
#' @param since numeric This is used to receive incremental updates.
#' Use the value of last from previous fixtures response.
#' @param isLive boolean if TRUE retrieves ONLY live events
#'
#' @return list of lists
#' @export
#' @import httr
#' @import jsonlite
#' @examples
#' GetOdds (sportname="Soccer", leagueid=c(11,45),since=26142345,isLive=0)
#'

GetOdds <-
  function(sportname,leagueIds,since=NULL,isLive=0){
    CheckTermsAndConditions()
    if (missing(sportname))
      stop("SportName is not optional")
    
    
    sportid <- GetSports(FALSE)[,"SportID"][sportname== GetSports(FALSE)[,"SportName"]]
    PossibleLeagueIds = GetLeaguesByID(sportid)
    PossibleLeagueIds = PossibleLeagueIds$LeagueID[PossibleLeagueIds$LinesAvailable==1]
    if(missing(leagueIds))
      leagueIds <- PossibleLeagueIds
    
    if(any(!(leagueIds %in% PossibleLeagueIds))) {
      warning(paste("The Following leagues do not have bettable lines and have been excluded from the output:",paste(leagueIds[!(leagueIds %in% PossibleLeagueIds)], collapse=",")))
      leagueIds = intersect(leagueIds,PossibleLeagueIds)
    }
    
    
    r <- GET(paste0(.PinnacleAPI$url ,"/v1/odds"),
             add_headers(Authorization= authorization(),
                         "Content-Type" = "application/json"),
             query = list(sportid=sportid,
                          leagueIds = paste(leagueIds,collapse=','),
                          since=since,
                          isLive=isLive*1))
    
    res <- jsonlite::fromJSON(content(r,type="text"),simplifyVector = FALSE)
    
    return(res)
  }


