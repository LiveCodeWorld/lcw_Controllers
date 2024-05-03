script "outlandish.lc"
getprop dep_StackNames
   return "lib_Fedwiki,lib_FedwikiRoster,lib_PageArray,model_Fedwiki,model_PageArray"
end dep_StackNames

on index
   transport_SetInfo wikiDomain, pageSlug, pageTitle
   --
   put atopia_FetchRoster ("outlandish.academy") into wikiDomains
   put roster_ConstructPageArray (wikiDomains) into pageArray
   transport_ReturnPageArray pageArray
end index
