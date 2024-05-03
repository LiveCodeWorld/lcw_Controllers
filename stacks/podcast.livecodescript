script "podcast.lc"
getprop dep_StackNames
   return "lib_Date,lib_Encoding,lib_Fedwiki,lib_Feed,lib_ListenNotes,lib_PageArray,lib_PageSection,lib_XML,model_PageArray"
end dep_StackNames

on index
   put transport_DroppedUrl() into droppedURL
   switch
      case qEnd is among the items of "ogg,mp3,m4A,wav"
         put pageArray_Construct ("Dropped Audio", "Drag audio file to anothe page...") into pageArray
         put fedwiki_ConstructImageCaption ("Dropped audio", droppedURL) into audioCaption
         pageArray_AddAudio pageArray, droppedURL, audioCaption
         transport_ReturnPageArray pageArray
         break
      case matchtext (droppedURL, "https://www.listennotes.com/podcasts/(.+)/(.+)", podcastSlug, episodeSlug)
         put listenNotes_PageArrayFromScrape (droppedURL) into pageArray
         transport_ReturnPageArray pageArray
         break
      case matchtext (droppedURL, "https://www.listennotes.com/podcasts/(.+)", podcastSlug)
         put listenNotes_ScrapePodcastID (droppedURL) into podcastID
         put listenNotes_FetchPodcastPageArray (podcastID) into pageArray
         transport_ReturnPageArray pageArray
         break
      default
         transport_ExitAndReturnError "Dropped url is not a ListenNotes url I recognise. :(", "Error"
   end switch
end index

command scrape_SetUserAgent
   -- HTTP_USER_AGENT Mozilla/5.0 (Macintosh; Intel Mac OS X 10.13; rv:62.0) Gecko/20100101 Firefox/62.0
   -- HTTP_USER_AGENT Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.106 Safari/537.36
   put "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.13; rv:62.0) Gecko/20100101 Firefox/62.0" into sHeader
   set the httpheaders to sHeader
end scrape_SetUserAgent

on test
   put "https://www.listennotes.com/podcasts/revolutions/725-the-parliament-of-dAFT1JL2irh/" into droppedURL
   scrape_SetUserAgent
   put url droppedURL into someHTML
   -- put shell ("curl" && droppedURL) into someHTML
   put the number of words of someHTML into wNum
   
   -- put textdecode (someHTML, "UTF-8") into someHtml
   put offset ("data-episode-uuid", someHtml) into wordNum
   if wordNum = 0 then
      put "Can't find:" && someHTML
   else
      get word wordNum of someHtml
      put token 7 of it into episodeID
      put "Found:" && it && episodeID &&  wNum
   end if
   
   /*
   
   -- put listenNotes_EpisodeID (someHtml)
   -- transport_ReturnError "Testing", it
   
   put listenNotes_FetchEpisodeID (droppedURL) into episodeID
   
   -- put listenNotes_PageArrayFromScrape (sURL) into pageArray
   put "0c60625d4dd942b2abb2ce3d26f690c0" into episodeID
   -- put "7.25- The Parliament of Professors" into searchTerm
   -- put listenNotes_EpisodeSearchPageArray (searchTerm) into pageArray
   
   put listenNotes_ConstructEpisodePageArray (episodeID) into pageArray
   transport_ReturnPageArray pageArray
   */
end test

on rss
   put _RssPageArray() into pageArray
   transport_ReturnPageArray pageArray
end rss

private function _RssPageArray
   put transport_GetDroppedArray() into postedArray
   put postedArray ["rssURL"] into rssURL
   if rssURL is empty then
      put "RSS url is empty!" & CR&CR & the keys of postedArray into mError
      transport_ExitAndReturnError mError, "Problem with Import"
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
   put transport_GetDroppedArray() into postedArray
   put postedArray ["search_Term"] into searchTerm
   if searchTerm is empty then transport_ExitAndReturnError "Search term is empty!", "Problem with search"
   
   put listenNotes_EpisodeSearchPageArray (searchTerm) into pageArray
   transport_ReturnPageArray pageArray
end findEpisode

on findEpisodeInPodcast
   put transport_GetDroppedArray() into postedArray
   put postedArray ["search_Term"] into searchTerm
   if searchTerm is empty then transport_ExitAndReturnError "Search term is empty!", "Problem with search"
   put postedArray ["podcastID"] into podcastID
   if podcastID is empty then transport_ExitAndReturnError "PodcastID is empty!", "Problem with search"
   
   -- put "Parliament of Professors" into searchTerm
   -- put "ed7b7197dba8478bae1e8ab6ea412d81" into podcastID
   -- put listenNotes_FetchEpisodeJSON (searchTerm, podcastID) into someJSON
   -- put someJSON
   
   put listenNotes_FindEpisode (searchTerm, podcastID) into foundEpisodeData
   put listenNotes_FoundPageArray (foundEpisodeData) into pageArray
   transport_ReturnPageArray pageArray
end findEpisodeInPodcast

on importEpisode
   put transport_GetDroppedArray() into postedArray
   put postedArray ["episodeID"] into episodeID
   if episodeID is empty then
      put merge ("This transporter cannot be used for this operation!") into errorText
      transport_ExitAndReturnError errorText, "Not a ListenNotes Episode"
   end if
   
   put listenNotes_ConstructEpisodePageArray (episodeID) into pageArray
   transport_ReturnPageArray pageArray
end importEpisode

on importPodcast
   -- the first after a search
   -- Used by wiki-button displayed on generated "Found Podcast" page
   
   put transport_GetDroppedArray() into postedArray
   put postedArray ["podcastID"] into podcastID
   -- put "8f0714068478481192cf9553881463d9" into podcastID
   --
   if podcastID is empty then
      put merge ("This transporter cannot be used for this operation!") into errorText
      transport_ExitAndReturnError errorText, "Not a Fedwiki URL"
   end if
   --
   put listenNotes_FetchPodcastPageArray (podcastID) into pageArray
   transport_ReturnPageArray pageArray
end importPodcast

on updateRecent
   /*
   put "Babbage from Economist Radio" into pageTitle
   put "43e615fb2f0646d3b02a58a751cd6bd1" into podcastID
   */
   put transport_GetDroppedArray() into postedArray
   put postedArray ["pageTitle"] into pageTitle
   put postedArray ["podcastID"] into podcastID
   --
   if podcastID is empty then
      put merge ("This transporter requires and podcast id and cannot be used for this operation!") into errorText
      transport_ExitAndReturnError errorText, "Transport Error"
   end if
   --
   put listenNotes_FetchUpdatesPodcastPageArray (podcastID, pageTitle) into pageArray
   transport_ReturnPageArray pageArray
end updateRecent

on findPodcast
   put transport_GetDroppedArray() into postedArray
   put postedArray ["search_Term"] into searchTerm
   -- put "Economist" into searchTerm
   --
   if searchTerm is empty then
      put merge ("This transporter cannot be used for this operation!") into errorText
      transport_ExitAndReturnError errorText, "Not a Fedwiki URL"
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
   transport_ReturnPageArray pageArray
end findPodcast
