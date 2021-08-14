script "update.lc"
getprop dep_StackNames
   return "lib_AtopiaCreation,lib_AtopiaTrash,lib_AtopiaTree,lib_Azure,lib_Fedwiki,lib_FedwikiSitemap,lib_Image,lib_PageArray,model_Atopia,model_AtopiaFiles,model_Fedray,model_PageArray,model_Transport"
end dep_StackNames

on index
   put atopia_ConstructCatModel() into atopiaCatModel
   --
   transport_StoreAtopiaCatModel atopiaCatModel
   --
   put atopia_ConstructLastAtopiaUpdatePageArray (atopiaCatModel) into pageArray
   fedwiki_ReturnPageArray pageArray
end index

on atopia
   atopia_TrashAndUpdateModified
   put the result into atopiaCatModel
   --
   put atopia_ConstructLastAtopiaUpdatePageArray (atopiaCatModel) into pageArray
   fedwiki_ReturnPageArray pageArray
end atopia

on recentSites
   put transport_FetchAtopiaCatModel() into atopiaCatModel
   --
   atopia_UpdateModified atopiaCatModel
   --
   put atopia_ConstructLastAtopiaUpdatePageArray (atopiaCatModel) into pageArray
   fedwiki_ReturnPageArray pageArray
end recentSites

on addNew
   -- put transport_FetchAtopiaCatModel() into atopiaCatModel
   -- put atopiaCatModel ["new sites"] into newDomainArray
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
   fedwiki_ReturnPageArray pageArray
end addNew

on createSite
   put "azuraye.goaljam.org" into newDomain
   /*
   put fedwiki_GetDroppedArray() into postArray
   put postArray ["wikiDomain"] into newDomain
   */
   --
   put pageArray_FetchNewSite (newDomain) into pageArray
   --
   fedwiki_ReturnPageArray pageArray
end createSite

on spam
   put transport_FetchAtopiaCatModel() into atopiaCatModel
   --
   atopia_TrashSpam atopiaCatModel
   --
   put the result into pageArray
   fedwiki_ReturnPageArray pageArray
end spam
