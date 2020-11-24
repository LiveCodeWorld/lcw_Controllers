script "podcast.lc"
getprop dep_StackNames
    return "lib_Date,lib_Encoding,lib_Fedwiki,lib_Feed,lib_ListenNotes,lib_PageArray,lib_XML,model_PageArray"
end dep_StackNames

on index
   put fedwiki_GetDroppedUrl() into droppedURL
   switch
      case fedwiki_IsFaviconDrop (dropJSON)
         fedwiki_ForwardAndReturn "https://rest.livecode.world/mediawiki"
         break
      case matchText (droppedURL, "https://(.+).wikipedia.org/wiki/(.+)", wikiLanguage, wikiSlug)
         fedwiki_ForwardAndReturn "https://rest.livecode.world/mediawiki"
         break
      case matchtext (droppedURL, "https://www.listennotes.com/podcasts/(.+)/(.+)", podcastSlug, episodeSlug)
         put listenNotes_PageArrayFromScrape (droppedURL) into pageArray
         fedwiki_ReturnPageArray pageArray
         break
      case matchtext (droppedURL, "https://www.listennotes.com/podcasts/(.+)", podcastSlug)
         put listenNotes_ScrapePodcastID (droppedURL) into podcastID
         put listenNotes_FetchPodcastPageArray (podcastID) into pageArray
         fedwiki_ReturnPageArray pageArray
         break
      default
         fedwiki_ExitAndReturnError "Dropped url is not a ListenNotes url I recognise. :(", "Error"
   end switch
end index

on testRSS
   put _RssPageArray() into pageArray
   --
   put fedwiki_GetDroppedArray() into postedArray
   put postedArray ["itemNum"] into itemNum
   pageArray_Trim pageArray, itemNum
   --
   fedwiki_ReturnPageArray pageArray
end testRSS

on rss
   put _RssPageArray() into pageArray
   fedwiki_ReturnPageArray pageArray
end rss

private function _RssPageArray
   put fedwiki_GetDroppedArray() into postedArray
   put postedArray ["rssURL"] into rssURL
   if rssURL is empty then
      put "RSS url is empty!" & CR&CR & the keys of postedArray into mError
      fedwiki_ExitAndReturnError mError, "Problem with Import"
   end if
   
   put postedArray ["wikiDomain"] into wikiDomain
   put postedArray ["pageTitle"] into pageTitle
   put postedArray ["rssLastUpdated"] into rssLastUpdated
   put postedArray ["displayStyle"] into displayStyle
   put postedArray ["cleanHow"] into cleanHow
   --
   put rss_GetPageArray (rssURL, rssLastUpdated, pageTitle, wikiDomain, displayStyle, cleanHow) into pageArray
   return pageArray
end _RssPageArray

on findEpisode
   put fedwiki_GetDroppedArray() into postedArray
   put postedArray ["search_Term"] into searchTerm
   if searchTerm is empty then fedwiki_ExitAndReturnError "Search term is empty!", "Problem with search"
   
   put listenNotes_EpisodeSearchPageArray (searchTerm) into pageArray
   fedwiki_ReturnPageArray pageArray
end findEpisode

on findEpisodeInPodcast
   put fedwiki_GetDroppedArray() into postedArray
   put postedArray ["search_Term"] into searchTerm
   if searchTerm is empty then fedwiki_ExitAndReturnError "Search term is empty!", "Problem with search"
   put postedArray ["podcastID"] into podcastID
   if podcastID is empty then fedwiki_ExitAndReturnError "PodcastID is empty!", "Problem with search"
   
   put listenNotes_FindEpisode (searchTerm, podcastID) into foundEpisodeData
   put listenNotes_FoundPageArray (foundEpisodeData) into pageArray
   fedwiki_ReturnPageArray pageArray
end findEpisodeInPodcast

on importEpisode
   put fedwiki_GetDroppedArray() into postedArray
   put postedArray ["episodeID"] into episodeID
   if episodeID is empty then
      put merge ("This transporter cannot be used for this operation!") into errorText
      fedwiki_ExitAndReturnError errorText, "Not a ListenNotes Episode"
   end if
   
   put listenNotes_ConstructEpisodePageArray (episodeID) into pageArray
   fedwiki_ReturnPageArray pageArray
end importEpisode

on importPodcast
   put fedwiki_GetDroppedArray() into postedArray
   put postedArray ["podcastID"] into podcastID
   -- put "8f0714068478481192cf9553881463d9" into podcastID
   --
   if podcastID is empty then
      put merge ("This transporter cannot be used for this operation!") into errorText
      fedwiki_ExitAndReturnError errorText, "Not a Fedwiki URL"
   end if
   --
   put listenNotes_FetchPodcastPageArray (podcastID) into pageArray
   fedwiki_ReturnPageArray pageArray
end importPodcast

on findPodcast
   put fedwiki_GetDroppedArray() into postedArray
   put postedArray ["search_Term"] into searchTerm
   -- put "Economist" into searchTerm
   --
   if searchTerm is empty then
      put merge ("This transporter cannot be used for this operation!") into errorText
      fedwiki_ExitAndReturnError errorText, "Not a Fedwiki URL"
   end if
   --
   put "Here is a list of some podcasts I found with these search terms..." into someMarkdown
   put pageArray_Construct ("Found Podcasts", someMarkdown) into pageArray
   --
   put listenNotes_FindPodcast (searchTerm) into resultArray
   put resultArray ["results"] into paginatedResultArray
   repeat with itemNum = 1 to item 2 of the extents of paginatedResultArray
      put paginatedResultArray [itemNum] into itemArray
      --
      put itemArray ["title_original"] into podcastTitle
      put itemArray ["id"] into podcastID
      --
      put podcast_ConstructButton (podcastTitle, podcastID, false) into btnHTML
      pageArray_AddHtml pageArray, btnHTML
   end repeat
   --
   fedwiki_ReturnPageArray pageArray
end findPodcast
