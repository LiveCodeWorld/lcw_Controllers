script "fedwiki.lc"
getprop dep_StackNames
   return "lib_AtopiaTree,lib_Fedwiki,lib_FedwikiRoster,lib_PageArray,lib_PageSection,model_PageArray"
end dep_StackNames


--> Only work with LiveServer for now
-
on form_UpdateSiteMap requestArray
   put transport_RefererDomain (requestArray) into wikiDomain
   --
   wikiSiteMap_Create wikiDomain
   --
   put merge ("Updated sitemap for '[[wikiDomain]]'.") into sMarkDown
   put pageArray_Construct ("Success!", sMarkDown, "markdown") into pageArray
   --
   -- daemon_SendArray socketID, pageArray
   -- return "Sent JSON. Socket still open."
   transport_ReturnPageArray pageArray
end form_UpdateSiteMap

on form_UpdateSiteTools requestArray
   put transport_RefererDomain (requestArray) into wikiDomain
   --
   wikiServer_CopyPageToDefault wikiDomain, "site-tools", "fedwiki.org"
   --
   put pageArray_Construct ("Success!", "Copied page [[Site Tools]] to default location.", "markdown") into pageArray
   transport_ReturnPageArray pageArray
end form_UpdateSiteTools


--> Transporter
-
on index
   -- roster_ReturnPageArray "fedwiki.org"
   atopia_ReturnRoster "fedwiki.org"
end index

on add_GreenBorder
   transport_SetInfo wikiDomain, pageSlug, pageTitle
   put the result into postData
   put postData ["pluginName"] into pluginName
   if pluginName is empty then put "markdown" into pluginName
   --
   put pageArray_Get (wikiDomain, pageSlug) into pageArray
   put pluginName into pageArray ["plugin"]
   --
   transport_ReturnPageArray pageArray
end add_GreenBorder

on remove_GreenBorder
   transport_SetInfo wikiDomain, pageSlug, pageTitle
   --
   put pageArray_Get (wikiDomain, pageSlug) into pageArray
   delete variable pageArray ["plugin"]
   --
   transport_ReturnPageArray pageArray
end remove_GreenBorder

on augment
   transport_SetInfo wikiDomain, pageSlug, pageTitle
   --
   put pageArray_FetchText (wikiDomain, pageSlug) into pageText
   get pageArray_Construct ("Test", pageText, "markdown")
   -- get pageArray_Construct ("Not Done Yet", "These tools have not been created yet!", "markdown")
   --
   transport_ReturnPageArray it
end augment

on clean_Title   
   put transport_FetchDroppedPageArray() into pageArray
   put pageArray_EditTitle (pageArray) into pageArray
   transport_ReturnPageArray pageArray
end clean_Title

on form_EditMedia
   transport_SetInfo wikiDomain, pageSlug, pageTitle
   --
   put pageArray_Fetch (wikiDomain, pageSlug) into pageArray
   get pageArray_Construct ("Not Done Yet", "These tools have not been created yet!", "markdown")
   --
   transport_ReturnPageArray it
end form_EditMedia

on form_AddDefault
   transport_SetInfo wikiDomain, pageSlug, pageTitle
   put "fedwiki.org" into forkDomains
   wikiServer_CopyPageToDefault wikiDomain, pageSlug, forkDomains
   --
   put pageArray_Construct ("Success!", "Copied page to default location.", "markdown") into pageArray
   transport_ReturnPageArray pageArray
end form_AddDefault

on form_EditTitle
   transport_SetInfo wikiDomain, pageSlug, pageTitle
   put pageArray_Fetch (wikiDomain, pageSlug) into pageArray
   --
   put pageArray_EditTitle (pageArray, pageTitle) into pageArray
   transport_ReturnPageArray pageArray
end form_EditTitle

on create_Wiki
   put transport_DroppedValue ("wikiDomain") into wikiDomain
   --
   wikiServer_Create wikiDomain
   --
   put merge ("Created new local wiki '[[wikiDomain]]'. Use these toools to create some initial content.") into sMarkdown
   put pageArray_Construct ("Site Construction", sMarkdown) into pageArray
   
   pageArray_AddReferenceIndex pageArray, wikiDomain
   --
   transport_ReturnPageArray pageArray
end create_Wiki

on create_Page requestArray
   put transport_RefererDomain (requestArray) into wikiDomain
   put transport_DroppedValue ("pageTitle") into pageTitle
   put fedwiki_ConstructSlug (pageTitle) into pageSlug
   --
   put pageArray_Construct (pageTitle, "Drag and drop [[page-flag]]s or media onto:") into pageArray
   repeat 6
      pageArray_AddFactory pageArray
   end repeat
   --
   put transport_ConstrutHiddenArray (wikiDomain, pageSlug, pageTitle) into hiddenArray
   pageArray_AddButton pageArray, "Compact", "http://rest.livecode.world/fedwiki/compact_Refs", hiddenArray
   --
   pageArray_StripJournal pageArray
   transport_ReturnPageArray pageArray
end create_Page

on compact_Refs
   transport_SetInfo wikiDomain, pageSlug, pageTitle
   --
   put pageArray_Fetch (wikiDomain, pageSlug) into pageArray
   pageArray_CompactRefs pageArray
   transport_ReturnPageArray pageArray
end compact_Refs

on strip_Journal
   transport_SetInfo wikiDomain, pageSlug, pageTitle
   --
   put pageArray_Fetch (wikiDomain, pageSlug) into pageArray
   pageArray_StripJournal pageArray
   delete variable pageArray ["plugin"]
   --
   transport_ReturnPageArray pageArray
end strip_Journal

on fork_Cleaner
   transport_SetInfo wikiDomain, pageSlug, pageTitle
   --
   put pageArray_Fetch (wikiDomain, pageSlug) into pageArray
   pageArray_CleanJournal pageArray, "create,fork"
   transport_ReturnPageArray pageArray
end fork_Cleaner

on addFedwiki
   transport_SetInfo wikiDomain, pageSlug, pageTitle
   --
   put "fedwiki.org" into forkDomains
   repeat for each item pNum in "3,4,5,6"
      put rigFetchSegment(pNum, "") into extraDomain
      if extraDomain is not false then put comma & extraDomain after forkDomains
   end repeat
   --
   put pageArray_Fetch (wikiDomain, pageSlug) into pageArray
   pageArray_StripJournal pageArray
   pageArray_AddFork pageArray, forkDomains
   transport_ReturnPageArray pageArray
end addFedwiki

on fix_Title
   put transport_DroppedUrl ($_POST_RAW) into droppedURL
   put pageArray_Fetch (droppedURL) into pageArray
   if pageArray is false then
      put merge ("The dropped url [[droppedURL]] is not a Fedwiki url.") into errorText
      transport_ExitAndReturnError errorText, "Not a Fedwiki URL"
   end if
   --
   put pageArray ["Title"] into pageTitle
   replace "-" with space in pageTitle
   put word 1 to -1 of pageTitle into pageTitle
   put text_InitialCaps (pageTitle) into pageTitle
   put pageTitle into pageArray ["Title"]
   --
   put json_FromArray (pageArray) into pageJSON
   transport_ReturnJSON pageJSON
end fix_Title

on clean_FirstLetter
   put transport_DroppedUrl ($_POST_RAW) into droppedURL
   put pageArray_Fetch (droppedURL) into pageArray
   --
   put pageArray ["Title"] into pageTitle
   put toUpper (char 1 of pageTitle) into char 1 of pageTitle
   put pageTitle into pageArray ["Title"]
   --
   put json_FromArray (pageArray) into pageJSON
   transport_ReturnJSON pageJSON
end clean_FirstLetter
