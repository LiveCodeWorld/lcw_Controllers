script "livecode.lc" with behavior "behavior_RigLocalOveride"
getprop dep_StackNames
   return "lib_Fedwiki,lib_PageArray,model_PageArray,lib_FedwikiRoster,lib_Federation"
end dep_StackNames

on index
   put atopia_FetchRoster ("livecode.world") into wikiDomains
   put roster_ConstructPageArray (wikiDomains) into pageArray
   fedwiki_ReturnPageArray pageArray
end index
