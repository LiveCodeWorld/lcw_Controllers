script "atopia.lc"
getprop dep_StackNames
    return "lib_AtopiaTree,lib_Fedwiki,lib_PageArray,model_Atopia,model_Fedray,model_PageArray,model_Transport"
end dep_StackNames

on index
   put atopia_ListSinceDomains ("1 week") into atopiaDomains  
   put "Recent Atopia Sites" & CR & CR & atopiaDomains into rosterText
   put roster_ConstructPageArray (rosterText) into pageArray
   fedwiki_ReturnPageArray pageArray
end index

on auth
   rigLoadHelper "jwt"
   -- put $_POST_RAW into userName
   put "fortyfoxes" into userName
   --
   put jwt_ConstructToken (userName) into tJWT
   put tJWT into tTokenA ["jwt"]
   
   # rigSetHeader DOES NOT WORK WITH AJAX, USE: put header ...
   # GENERATES AN OBJECT ON CLIENT SIDE. SO, DON'T USE JSON.parse() TO PROCESS THE DATA
   put header "Content-type: application/json; charset=UTF-8"
   put JsonExport (tTokenA)
end auth

on listModels
   put transport_GetModelFolder() into modelFolder
   put files (modelFolder) into atopiaModelShortFiles
   filter atopiaModelShortFiles without ".*"
   put atopiaModelShortFiles
end listModels

on writeModel
   put $_POST_RAW into rawJSON
   put textEncode (rawJSON) into encodedJSON
   put json_ToArray (encodedJSON) into postData
   --
   put rigFetchConfigItem ("TransportModel") into storedSecret
   put postData ["secret"] into someSecret
   --
   put postData ["modelName"] into modelName
   --
   if someSecret is storedSecret AND modelName is not empty then 
      put postData ["modelData"] into modelData
      --
      transport_SetModel modelName, modelData
      put the result into jsonPath
      put pageArray_Construct (word 1 of the params, jsonPath) into rPageArray
   else
      put pageArray_Construct ("Error", "Not authenticated") into rPageArray
   end if
   --
   fedwiki_ReturnPageArray rPageArray
end writeModel

on list
   put fedwiki_GetDroppedArray() into postArray
   put postArray ["outputType"] into outputType
   --
   put atopia_ListRecentDomains () into wikiDomains
   switch outputType
      case "top"
         put url_ListTopDomains (wikiDomains) into wikiDomains
         break
      default
   end switch
   url_SortDomainIndex wikiDomains
   put fedwiki_MarkdownIndex (wikiDomains) into markdownIndex
   --
   put postArray ["pageSlug"] into templateSlug
   put postArray ["wikiDomain"] into templateDomain
   put postArray ["itemID"] into itemID
   --
   put pageArray_Fetch (templateDomain, templateSlug) into pageArray
   pageArray_SetItemText pageArray, itemID, markdownIndex
   pageArray_StripJournal pageArray
   pageArray_AddFork pageArray, "sites.fedwiki.org"
   --
   fedwiki_ReturnPageArray pageArray   
end list

private function roster_ConstructPageArray rosterText, pRosterTitle
   if pRosterTitle is empty then
      put "Roster Page" into pageArray ["title"]
   else
      put pRosterTitle into pageArray ["title"]
      put pRosterTitle & CR & CR before rosterText
   end if
   
   replace comma with CR in rosterText
   --
   pageArray_AddRoster pageArray, rosterText
   pageArray_StripJournal pageArray
   return pageArray
end roster_ConstructPageArray
