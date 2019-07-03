script "scrape.lc" with behavior "behavior_RigLocalOveride"
getprop dep_StackNames
   return "lib_Fedwiki,lib_Scrape,lib_PageArray,lib_HTML,lib_Citation,lib_REST"
end dep_StackNames

on index
   put scrape_ConstructFedwikiPageArray (droppedURL, true, true, true) into pageArray
   fedwiki_ReturnPageArray pageArray
end index
