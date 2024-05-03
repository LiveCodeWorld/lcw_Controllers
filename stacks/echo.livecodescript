script "echo.lc"
getprop dep_StackNames
   return "lib_Fedwiki,lib_PageArray,model_PageArray"
end dep_StackNames

on index
   put _ConstructTestText() into someMarkdown
   -- put fedray_FetchDomains ("voz.money") into rosterDomains
   put $_SERVER into tServerArray
   put tServerArray ["PATH_TRANSLATED"] into pathTranslated
   -- combine tServerArray using CR and space -- makes a list for presenting
   
   put "# PATH_TRANSLATED" & CR after someMarkdown
   -- PATH_TRANSLATED /var/www/rest.livecode.world/index.lc
   put pathTranslated & CR after someMarkdown
   
   put "# HTTP_REFERER" & CR after someMarkdown
   put $HTTP_REFERER & CR after someMarkdown
   
   put cgi_TextPath ("hello.txt") into filePath
   put url ("file:" & filePath) into someText
   put CR after someMarkdown
   
   put "# gRoute" & CR after someMarkdown
   put the keys of gRoute & CR after someMarkdown
   put gRoute[2]["journals"] & CR after someMarkdown
   put the keys of gRoute[3] & CR after someMarkdown
   
   put "# Hello World" & CR after someMarkdown
   put someText & CR after someMarkdown
   
   -- put CR & "# Headers" after someMarkdown
   -- put libUrlLastRhHeaders() & CR after someMarkdown
   
   -- now write to database
   put CR after someMarkdown
   put "Hello world!" && the ticks into url ("file:" & textPath)
   
   put keys (tServerArray) & CR after someMarkdown
   put the filename of me & CR after someMarkdown -- /var/www/rest.livecode.world/index.lc is not what we want
   --
   put pageArray_Construct ("Echo", someMarkdown) into pageArray
   transport_ReturnPageArray pageArray
end index

on scaffold
   transport_SetFormSlugDomain wikiDomain, pageSlug
   put transport_GetFormValue ("snippetValue") into snippetResult -- "complete sentance
   --
   put snippet_CurlyResult (pageSlug, "snippet", snippetResult) into curlyResult
   get sSnippet & CR&CR & curlyResult & CR&CR & snippetResult
   --
   put snippet_CurlyResult (pageSlug, "snippet", snippetResult) into curlyResult
   
   put pageArray_Construct ("Echo", it) into pageArray
   transport_ReturnPageArray pageArray
end scaffold

function cgi_TextPath shortFile
   put tServerArray ["PATH_TRANSLATED"] into pathTranslated
   --
   set the itemdelimiter to slash
   put pathTranslated into textPath
   put shortFile into item -1 of textPath
   --
   return textPath
end cgi_TextPath

function _ConstructTestText
   local someText
   
   put "# Dropped URL transport_DroppedUrl()" & CR after someText
   --
   put transport_DroppedUrl() into droppedURL
   put droppedURL & CR after someText
   -- 
   put CR after someText
   --
   if the platform is "server" then
      rigLoaderLoadLibrary "Useragent"
      put rigBrowser() into tBrowser
      put "__Browser:__" && tBrowser & CR after someText
   end if
   --
   put transport_IsFaviconDrop() into isFavicon
   put "__Dropped favicon:__" && isFavicon & CR & CR after someText
   -- 
   put CR after someText
   --
   put "# $_POST_RAW" & CR after someText
   put $_POST_RAW & CR after someText
   --
   put CR after someText
   --
   put "# $_SERVER" & CR after someText
   put $_SERVER into tServerArray
   combine tServerArray using CR and space
   put tServerArray & CR after someText
   --
   /*
   -- rigSetConfigItem "bye", "hello"
   -- get rigFetchConfigItem ("bye")
   get youTube_GetApiKey()
   put "Config:" && it & CR & CR after someText
   */
   --
   delete char -1 of someText
   return someText
end _ConstructTestText

function _MoreText
   if the platform is not "server" then return empty
   
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
   if the platform is not "server" then return empty
   --
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
