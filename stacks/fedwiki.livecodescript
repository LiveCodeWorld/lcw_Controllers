script "fedwiki.lc"
getprop dep_StackNames
   return "lib_AtopiaTree,lib_Fedwiki,lib_FedwikiRoster,lib_FedwikiSitemap,lib_PageArray,model_Fedwiki,model_PageArray"
end dep_StackNames

on index
   -- roster_ReturnPageArray "fedwiki.org"
   atopia_ReturnRoster "fedwiki.org"
end index

on item_Number
   put rigFetchSegment(3, "") into wikiDomain
   put rigFetchSegment(4, "") into pageSlug
   put rigFetchSegment(5, "0") into itemNum   
   put pageArray_Fetch (wikiDomain, pageSlug) into pageArray
   
   switch
      case itemNum = 0
         put pageArray ["title"] into itemText
         break
      default
         -- put the number of chars of itemNum into cNum -- this is good
         put itemNum + 0 into itemNum -- bug (forces number)
         put pageArray ["story"][itemNum]["text"] into itemText
   end switch
   
   put itemText into returnArray ["text"]
   /*
   rigSetHeader "Content-type: application/json"
   rigSetHeader "Accept: application/json"
   rigSetHeader "Accept-Charset: utf-8"
   put word 1 to -1 of itemText
   */
   fedwiki_ReturnPageArray returnArray
end item_Number

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
