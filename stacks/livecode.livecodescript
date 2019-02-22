script "livecode.lc" with behavior "behavior_RigLocalOveride"
getprop dep_StackNames
   return "lib_Fedwiki,lib_AtopiaFetch,lib_FedwikiRoster"
end dep_StackNames

on index
   -- put atopia_FetchStoredDomains ("livecode.world") into wikiDomains
   put atopia_FetchRoster ("livecode.world") into wikiDomains
   put fedwiki_ConstructRosterPageArray (wikiDomains) into pageArray
   fedwiki_ReturnPageArray pageArray
end index
