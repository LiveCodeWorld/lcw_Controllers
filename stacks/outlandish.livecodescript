script "outlandish.lc"
getprop dep_StackNames
   return "lib_Fedwiki,lib_FedwikiRoster,lib_PageArray,model_Fedwiki,model_PageArray"
end dep_StackNames

on index
   fedwiki_DeconstructDroppedURL pageSlug, wikiDomain
   put atopia_FetchRoster ("outlandish.academy") into wikiDomains
   put roster_ConstructPageArray (wikiDomains) into pageArray
   fedwiki_ReturnPageArray pageArray
end index
