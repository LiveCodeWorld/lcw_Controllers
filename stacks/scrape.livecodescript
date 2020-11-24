script "scrape.lc"
getprop dep_StackNames
    return "lib_Fedwiki,lib_Scrape,lib_PageArray,lib_HTML,lib_Citation,lib_REST"
end dep_StackNames

on index
   put fedwiki_GetDroppedUrl() into droppedURL
   if droppedURL is empty then fedwiki_ExitAndReturnError "Dropped url is empty.", "Error"
   --
   put scrape_ConstructFedwikiPageArray (droppedURL, true, true, true) into pageArray
   fedwiki_ReturnPageArray pageArray
end index
