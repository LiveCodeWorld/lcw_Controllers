script "jam.lc"
getprop dep_StackNames
   return "lib_AtopiaTree,lib_Fedwiki,lib_FedwikiRoster,lib_FedwikiSitemap,lib_PageArray,model_Fedwiki,model_PageArray"
   -- return "lib_AtopiaTree,lib_Fedwiki,lib_FedwikiRoster,lib_PageArray,model_PageArray"
end dep_StackNames

on index
   atopia_ReturnRoster "gaiafest.org,festivaljam.org,festivaljam.xyz,goaljam.org,visualjam.org,visualjam.xyz,spacenet.work"
   /*
   put atopia_FetchTreeWelcomeInfoArray() into infoArray
   put the keys of infoArray into filteredAtopiaDomains
   filter filteredAtopiaDomains with "*jam*"
   url_SortDomainIndex filteredAtopiaDomains
   roster_ReturnFiltered filteredAtopiaDomains, "Jam Sites"
   */
end index
