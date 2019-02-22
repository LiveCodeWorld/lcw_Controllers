script "fedwiki.lc" with behavior "behavior_RigLocalOveride"
getprop dep_StackNames
   return "lib_Fedwiki,lib_FedwikiRoster,lib_AtopiaFetch"
end dep_StackNames

on index
   -- put atopia_FetchStoredDomains ("fedwiki.org") into wikiDomains -- uses json plugin
   put atopia_FetchRoster ("fedwiki.org") into wikiDomains
   put fedwiki_ConstructRosterPageArray (wikiDomains) into pageArray
   fedwiki_ReturnPageArray pageArray
end index

on compact_Refs
   put fedwiki_GetDroppedUrl ($_POST_RAW) into droppedURL
   if fedwiki_IsHtmlUrl (droppedURL, errorMsg) is false then
      put merge ("The dropped url [[droppedURL]] is not a [[Fedwiki HTML url]]. Use the link at the bottom of the page") into errorText
      fedwiki_ExitAndReturnError errorText, "Not a Fedwiki HTML URL"
   end if
   --
   fedwiki_DeconstructDroppedURL pageSlug, wikiDomain, droppedURL
   put fedwiki_FetchPageArray (wikiDomain, pageSlug) into pageArray
   fedwiki_CompactPageArrayRefs pageArray
   --
   fedwiki_ReturnPageArray pageArray
end compact_Refs

on fork_Cleaner
   fedwiki_DeconstructDroppedURL pageSlug, wikiDomain
   put fedwiki_FetchPageArray (wikiDomain, pageSlug) into pageArray
   --
   fedwiki_CleanJournalArray pageArray, "create,fork"
   --
   fedwiki_ReturnPageArray pageArray
end fork_Cleaner

on journal
   fedwiki_DeconstructDroppedURL pageSlug, wikiDomain
   put fedwiki_FetchPageArray (wikiDomain, pageSlug) into pageArray
   --
   fedwiki_CleanJournalArray pageArray
   --
   fedwiki_ReturnPageArray pageArray
end journal

on clean_Title
   put fedwiki_GetDroppedUrl ($_POST_RAW) into droppedURL
   put fedwiki_FetchPageArray (droppedURL) into pageArray
   --
   put pageArray ["Title"] into pageTitle
   -- put toUpper (char 1 of pageTitle) into char 1 of pageTitle
   put text_InitialCaps (pageTitle) into pageTitle
   put pageTitle into pageArray ["Title"]
   --
   put json_FromArray (pageArray) into pageJSON
   fedwiki_ReturnJSON pageJSON
end clean_Title

on fix_Title
   put fedwiki_GetDroppedUrl ($_POST_RAW) into droppedURL
   put fedwiki_FetchPageArray (droppedURL) into pageArray
   if pageArray is false then
      put merge ("The dropped url [[droppedURL]] is not a Fedwiki url.") into errorText
      fedwiki_ExitAndReturnError errorText, "Not a Fedwiki URL"
   end if
   --
   put pageArray ["Title"] into pageTitle
   replace "-" with space in pageTitle
   put word 1 to -1 of pageTitle into pageTitle
   put text_InitialCaps (pageTitle) into pageTitle
   put pageTitle into pageArray ["Title"]
   --
   put json_FromArray (pageArray) into pageJSON
   fedwiki_ReturnJSON pageJSON
end fix_Title

on clean_FirstLetter
   put fedwiki_GetDroppedUrl ($_POST_RAW) into droppedURL
   put fedwiki_FetchPageArray (droppedURL) into pageArray
   --
   put pageArray ["Title"] into pageTitle
   put toUpper (char 1 of pageTitle) into char 1 of pageTitle
   put pageTitle into pageArray ["Title"]
   --
   put json_FromArray (pageArray) into pageJSON
   fedwiki_ReturnJSON pageJSON
end clean_FirstLetter
