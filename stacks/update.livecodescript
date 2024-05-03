script "update.lc"
getprop dep_StackNames
   return "lib_AtopiaCreation,lib_AtopiaTrash,lib_AtopiaTree,lib_Fedwiki,lib_FedwikiSitemap,lib_PageArray,model_AtopiaFiles,model_PageArray,model_Transport"
end dep_StackNames

on index
   put atopia_ConstructCatModel() into atopiaCatModel
   atopia_StoreCatModel atopiaCatModel
   --
   put atopia_ConstructLastAtopiaUpdatePageArray (atopiaCatModel) into pageArray
   transport_ReturnPageArray pageArray
end index

on trashAndIndex
   put atopia_ConstructCatModel() into atopiaCatModel
   atopia_TrashAndIndex atopiaCatModel
   put the result into statusData
   put statusData ["trashAndIndexTime"] into trashAndIndexTime
   --
   put "Trashing and indexing the Atoppia Server took:" && trashAndIndexTime into someMarkdown
   put pageArray_Construct ("Fedray Update Report", someMarkdown) into pageArray
   transport_ReturnPageArray pageArray
end trashAndIndex

on atopia
   atopia_TrashAndUpdateModified
   put the result into atopiaCatModel
   --
   put atopia_ConstructLastAtopiaUpdatePageArray (atopiaCatModel) into pageArray
   transport_ReturnPageArray pageArray
end atopia

on recentSites
   put atopia_FetchCatModel() into atopiaCatModel
   --
   atopia_UpdateModified atopiaCatModel
   --
   put atopia_ConstructLastAtopiaUpdatePageArray (atopiaCatModel) into pageArray
   transport_ReturnPageArray pageArray
end recentSites

on addNew
   put atopia_ListNewCatFolders() into newAtopiaDomains
   --
   get "Below we list any new sites that have been created since the [[Last Update]] on the [[Atopia server]]:"
   put pageArray_Construct ("New Sites", it) into pageArray
   --
   repeat for each line newDomain in newAtopiaDomains
      put atopia_ConstructNewSiteButton (newDomain) into btnHTML
      pageArray_AddHtml pageArray, btnHTML
   end repeat
   --
   transport_ReturnPageArray pageArray
end addNew

on spam
   put atopia_FetchCatModel() into atopiaCatModel
   --
   atopia_TrashSpam atopiaCatModel
   --
   put the result into pageArray
   transport_ReturnPageArray pageArray
end spam
