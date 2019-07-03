script "fedwiki.lc"
getprop dep_StackNames
    return "lib_Fedwiki,lib_FedwikiRoster,lib_PageArray,model_PageArray"
end dep_StackNames

on index
   fedwiki_DeconstructDroppedURL pageSlug, wikiDomain
   put atopia_FetchRoster ("fedwiki.org") into wikiDomains
   put roster_ConstructPageArray (wikiDomains) into pageArray
   fedwiki_ReturnPageArray pageArray
end index

on compact_Refs
   fedwiki_DeconstructDroppedURL pageSlug, wikiDomain
   put pageArray_Fetch (wikiDomain, pageSlug) into pageArray
   pageArray_CompactRefs pageArray
   fedwiki_ReturnPageArray pageArray
end compact_Refs

on journal
   fedwiki_DeconstructDroppedURL pageSlug, wikiDomain
   put pageArray_Fetch (wikiDomain, pageSlug) into pageArray
   pageArray_StripJournal pageArray
   fedwiki_ReturnPageArray pageArray
end journal

on fork_Cleaner
   fedwiki_DeconstructDroppedURL pageSlug, wikiDomain
   put pageArray_Fetch (wikiDomain, pageSlug) into pageArray
   pageArray_CleanJournal pageArray, "create,fork"
   fedwiki_ReturnPageArray pageArray
end fork_Cleaner

on addFedwiki
   put "fedwiki.org" into forkDomains
   repeat for each item pNum in "3,4,5,6"
      put rigFetchSegment(pNum, "") into extraDomain
      if extraDomain is not false then put comma & extraDomain after forkDomains
   end repeat
   --
   fedwiki_DeconstructDroppedURL pageSlug, wikiDomain
   put pageArray_Fetch (wikiDomain, pageSlug) into pageArray
   pageArray_StripJournal pageArray
   pageArray_AddFork pageArray, forkDomains
   fedwiki_ReturnPageArray pageArray
end addFedwiki

on clean_Title
   put fedwiki_GetDroppedUrl ($_POST_RAW) into droppedURL
   put pageArray_Fetch (droppedURL) into pageArray
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
   put pageArray_Fetch (droppedURL) into pageArray
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
   put pageArray_Fetch (droppedURL) into pageArray
   --
   put pageArray ["Title"] into pageTitle
   put toUpper (char 1 of pageTitle) into char 1 of pageTitle
   put pageTitle into pageArray ["Title"]
   --
   put json_FromArray (pageArray) into pageJSON
   fedwiki_ReturnJSON pageJSON
end clean_FirstLetter
