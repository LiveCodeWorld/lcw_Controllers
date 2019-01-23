script "echo.lc" with behavior "behavior_RigLocalOveride"
getprop dep_StackNames
   return "lib_Fedwiki,lib_FedwikiCreate"
end dep_StackNames

on index
   put _ConstructTestText() into someText
   put fedwiki_ConstructErrorJSON (someText) into someJSON
   fedwiki_ReturnJSON someJSON
end index

on form
   -- a test of using a wiki page as a form
   put fedwiki_GetDroppedArray() into postArray
   put postArray ["wikiDomain"] into wikiDomain
   put postArray ["pageSlug"] into pageSlug
   --
   put fedwiki_FetchPageArray (wikiDomain, pageSlug) into pageArray
   put pageArray ["title"] into pageTitle
   put "Fetched from:" && pageTitle into someTitle
   put fedwiki_FindFirstStoryItemText (pageArray) into itemText
   --
   -- put json_FromArray (dropArray) into itemText
   put fedwiki_ConstructErrorJSON (itemText, someTitle) into someJSON
   fedwiki_ReturnJSON someJSON
end form

function _ConstructTestText
   put fedwiki_GetDroppedUrl ($_POST_RAW) into droppedURL
   put droppedURL & CR & $REQUEST_URI into someText
   -- 
   put CR & CR after someText
   --
   rigLoaderLoadLibrary "Useragent"
   put rigBrowser() into tBrowser
   put "Browser:" && tBrowser & CR & CR after someText
   --
   put fedwiki_IsFaviconDrop() into isFavicon
   put "Dropped favicon:" && isFavicon & CR & CR after someText
   --
   /*
   -- rigSetConfigItem "bye", "hello"
   -- get rigFetchConfigItem ("bye")
   get youTube_GetApiKey()
   put "Config:" && it & CR & CR after someText
   */
   --
   put $_POST_RAW after someText
   --
   put $_SERVER into tServerArray
   combine tServerArray using CR and space
   put CR & CR & tServerArray after someText
   --
   return someText
end _ConstructTestText

function _MoreText
   put rigUserAgent() into tUserAgent
   put rigVarCookie ("wikisession") into someCookie
   put rigVarGet() into getData
   --
   put tUserAgent & CR & someCookie after someText
   put CR & CR & rigIpAddress() after someText
   --
   put rigUriToAssoc() into segmentArray
   -- put json_FromArray(segmentArray) into someText
   repeat for each key tKey in segmentArray
      put segmentArray [tKey] into tSegment
      put tSegment & CR after someText
   end repeat
   return someText
end _MoreText

on myip
   put rigIpAddress() after myIP
   put myIP
end myip

on postraw
   set the itemdelimiter to "&"
   repeat for each item tVariablePair in $_POST_RAW
      set the itemdelimiter to "="
      put urlDecode(item 1 of tVariablePair) into tVariableKey
      put urlDecode(item 2 of tVariablePair) into tVariableValue
      -- do something with key and value --
      put  tVariableKey & ":" && tVariableValue & CR after someText
      set the itemdelimiter to "&"
   end repeat
   put someText
end postraw

on server
   put $_SERVER into someText
   combine someText using CR and space
   put someText
end server
