script "bbc.lc" with behavior "behavior_RigLocalOveride"
getprop dep_StackNames
   return "lib_Fedwiki,lib_HTML,lib_PageArray,lib_Podcast,lib_Scrape,model_Secret"
end dep_StackNames

on index
   put fedwiki_GetDroppedUrl ($_POST_RAW) into droppedURL
   if droppedURL is empty then fedwiki_ExitAndReturnError "Dropped url is empty.", "Error"
   
   switch
      case matchtext (droppedURL, "https://www.listennotes.com/podcasts/(.+)", podBit)
         -- "https://www.listennotes.com/podcasts/the-documentary/a-short-history-of-story-_jn1cUKCStO/"
         listenNotes
         break
      case matchtext (droppedURL, "https://player.fm/(.+)/bookmarks/all", userName)
         fedwiki_ExitAndReturnError "Bookmarks not done yet!", "Not done yet!"
         break
      case droppedURL begins with "https://player.fm/series/"
         playerfm
         break
      case droppedURL begins with "https://www.theguardian.com/science/audio/" -- plenty of other podcast urls
         guardian
         break
      case droppedURL begins with "http://www.radiolab.org/story/"
         radioLab
         break
      case droppedURL begins with "https://www.bbc.co.uk/programmes/"
      case droppedURL begins with "http://www.bbc.co.uk/programmes/"
         if droppedURL ends with "#play" then
            delete char -5 to -1 of droppedURL
         end if
         -- put "https://www.bbc.co.uk/programmes/b04p7yg3" into droppedURL
         put url droppedURL into someHTML 
         put bbc_FetchPodcastPageArray (someHtml, droppedURL) into pageArray
         fedwiki_ReturnPageArray pageArray
         break
      default
         _SetDroppedHtml someHTML, droppedURL
         put scrape_HeaderSection (someHTML) into metaArray
         put metaArray ["title"] into htmlTitle
         fedwiki_ExitAndReturnError "Dropped url is notr recognised.", "Error"
   end switch
end index

on listenNotes   
   put fedwiki_GetDroppedUrl ($_POST_RAW) into droppedURL
   switch
      case matchtext (droppedURL, "https://www.listennotes.com/podcasts/(.+)/(.+)", podcastSlug, episodeSlug)
         -- https://www.listennotes.com/podcasts/wiki-politiki/unity-earth-festival-focuses-ypSB83WRk1U/
         put listenNotes_ScrapeEpisodeID (droppedURL) into episodeID
         put listenNotes_ConstructEpisodePageArray (episodeID) into pageArray
         fedwiki_ReturnPageArray pageArray
         break
      case matchtext (droppedURL, "https://www.listennotes.com/podcasts/(.+)", podcastSlug)
         -- https://www.listennotes.com/podcasts/wiki-politiki-iom-radio-network-omtimes-Oni9JDfeoaP/
         fedwiki_ExitAndReturnError "Not implemented importing podcast description yet.", "Not done yet!"
         break
      default
         fedwiki_ExitAndReturnError "Dropped url is not a ListenNotes url I recognise. :(", "Error"
   end switch
end listenNotes

on test
   /*
   put fedwiki_GetDroppedUrl ($_POST_RAW) into droppedURL
   put listenNotes_ScrapeEpisodeID (droppedURL) into episodeID
   --
   put listenNotes_ConstructEpisodePageArray (episodeID) into pageArray
   fedwiki_ReturnPageArray pageArray
   */
   
   put listenNotes_GetRapidApiKey() into apiKey
   fedwiki_ExitAndReturnError apiKey, "Scraped Episode ID"
   
   /*
   put kwote ("A Short History Of Story: Part one") into searchTerm
   put lcw_Ask ("Enter episode term", searchTerm) into searchTerm
   --
   put listeNotes_SearchAndConstructPageArray (searchTerm) into pageArray
   fedwiki_ReturnPageArray pageArray
   */
end test

on listenMore
    put fedwiki_GetDroppedArray() into postArray
   --
   put postArray ["search_Term"] into googleQuery
   put postArray ["search_Offset"] into cseOffset
   -- put postArray ["password"] into somePword
   --
   put listenNotes_SearchAndConstructPageArray (googleQuery, somePword, cseOffset, cseName) into pageArray
   fedwiki_ReturnPageArray pageArray
end listenMore

on guardian
   _SetDroppedHtml someHTML, droppedURL
   put guardian_FetchPodcastPageArray (someHtml, droppedURL) into pageArray
end guardian

on radioLab
   -- put "http://www.radiolab.org/story/the_political_thicket/" into droppedURL
   _SetDroppedHtml someHTML, droppedURL
   put radiolab_FetchPodcastPageArray (someHTML) into pageArray
   return pageArray
end radioLab

on playerfm
   put fedwiki_GetDroppedUrl () into droppedURL
   put playerfm_FetchArray (droppedURL) into playerfmArray
   put playerfm_ConstructPageArray (playerfmArray) into pageArray
   fedwiki_ReturnPageArray pageArray
end playerfm

private command _SetDroppedHtml @someHTML, @droppedURL
   put fedwiki_GetDroppedUrl ($_POST_RAW) into droppedURL 
   put html_FetchTidy (droppedURL) into someHTML
   if someHTML is empty then
      fedwiki_ExitAndReturnError "Dropped html is empty.", "Error"
   end if
   return someHTML
end _SetDroppedHtml
