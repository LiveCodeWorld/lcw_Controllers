script "search.lc" with behavior "behavior_RigLocalOveride"
getprop dep_StackNames
   return "lib_Fedwiki,lib_GoogleCustomSearch,lib_Encoding,model_Secret"
end dep_StackNames

on index
   -- put fedwiki_GetDroppedUrl ($_POST_RAW) into someUrl
   -- put fedwiki_ConstructErrorJSON ($_POST_RAW) into someJSON
   -- fedwiki_ReturnJSON someJSON
   
   put cse_ConstructPostArray ("Federation", "wiki") into postArray
   cse_DeconstructPostArray postArray, cseName, googleQuery, pWord, cseOffset
   put cse_SearchAndConstructPageArray (googleQuery, pWord, cseOffset, cseName) into pageArray
   --
   fedwiki_ReturnPageArray pageArray
end index

on cse
   put fedwiki_GetDroppedArray() into postArray
   --
   cse_DeconstructPostArray postArray, cseName, googleQuery, pWord, cseOffset
   put cse_SearchAndConstructPageArray (googleQuery, pWord, cseOffset, cseName) into pageArray
   --
   -- fedwiki_ReturnPageArray pageArray
   put json_FromArray (pageArray) into someJSON
   replace "\u0022" with quote in someJSON
   fedwiki_ReturnJSON someJSON
end cse

on tsv
   if the environment = "server" then
      put fedwiki_GetDroppedArray() into postArray
   else
      put _ConstractPostArray ("741a0fcdd3ff76b2", "livecode.world", "roster-maker", "transport.fedwiki.org") into postArray
   end if
   _DeconstractPostArray postArray, itemID, domainFilter, templateSlug, templateDomain
   --
   put google_ConstructTSV (someDomains, pCseID)
   
   -- put fedwiki_UpdateRosterPageArray (templateDomain, templateSlug, itemID, rosterDomainText) into pageArray
   --
   fedwiki_ReturnPageArray pageArray   
end tsv
