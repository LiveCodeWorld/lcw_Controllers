script "atopia.lc"
getprop dep_StackNames
   return "lib_AtopiaTree,lib_AtopiaUpdate,lib_Date,lib_Fedwiki,lib_FedwikiRoster,lib_PageArray,lib_Transport,model_Atopia,model_PageArray,model_Transport"
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

on deleteModel
   put $_POST_RAW into rawJSON
   put json_ToArray (rawJSON) into postData
   --
   put rigFetchConfigItem ("TransportModel") into storedSecret
   put postData ["secret"] into someSecret
   put postData ["modelName"] into modelName
   --
   if someSecret is storedSecret AND modelName is not empty then 
      transport_DeleteModel modelName
      put the result into deleteResult
      if item 1 of deleteResult = "error" then
         put pageArray_Construct ("Error", deleteResult) into rPageArray
      else
         put pageArray_Construct (word 1 of the params, deleteResult) into rPageArray
      end if
   else
      put pageArray_Construct ("Error", "Not authenticated") into rPageArray
   end if
   --
   fedwiki_ReturnPageArray rPageArray
end deleteModel

on deleteShortModelFile
   put $_POST_RAW into rawJSON
   put json_ToArray (rawJSON) into postData
   --
   put rigFetchConfigItem ("TransportModel") into storedSecret
   put postData ["secret"] into someSecret
   put postData ["shortModelFile"] into shortModelFile
   --
   if someSecret is storedSecret AND shortModelFile is not empty then 
      transport_DeleteShortModelFile shortModelFile
      put the result into deleteResult
      --
      if item 1 of deleteResult = "error" then
         put pageArray_Construct ("Error", deleteResult) into rPageArray
      else
         put pageArray_Construct (word 1 of the params, deleteResult) into rPageArray
      end if
   else
      put pageArray_Construct ("Error", "Not authenticated") into rPageArray
   end if
   --
   fedwiki_ReturnPageArray rPageArray
end deleteShortModelFile

on writeModel
   -- put rigVarPost (modelName) into modelData
   put $_POST_RAW into rawJSON
   put json_ToArray (rawJSON) into postData
   --
   put rigFetchConfigItem ("TransportModel") into storedSecret
   put postData ["secret"] into someSecret
   --
   -- put rigFetchSegment (3, "Atopia Model") into modelName
   put postData ["modelName"] into modelName
   --
   if someSecret is storedSecret AND modelName is not empty then 
      put postData ["modelData"] into modelData
      --
      transport_WriteModel modelName, modelData
      put the result into jsonPath
      --
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
