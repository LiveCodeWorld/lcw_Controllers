script "script.lc"
getprop dep_StackNames
    return "lib_Fedwiki,lib_FedWikiPedia,lib_MediaWiki"
end dep_StackNames

on index
   local pNotTheseSlugs
   put fedwiki_GetDroppedUrl ($_POST_RAW) into droppedURL
   put fedwiki_FetchLastLineUpArray (droppedURL, pNotTheseSlugs) into pageArray
   put fedwiki_ExtractFirstStoryItem (pageArray, "code") into someCode
   
   fedwiki_ReturnError someCode, "There is no code on the last lineup wiki-page!"
   put "Here we experiment creating a simple code page. You will find the code below:" into pSomeText
   put fedwiki_ConstructCodePageArray ("Test Code page", someCode, pSomeText) into pageArray
   put json_FromArray (pageArray) into someJSON
   
   fedwiki_ReturnJSON someJSON
end index
