script "recent.lc" with behavior "behavior_RigLocalOveride"
getprop dep_StackNames
   return "lib_Federation,lib_Fedwiki,lib_FedwikiRoster,lib_PageArray,model_AtopiaAuthors,model_Federation,model_Fedwiki"
end dep_StackNames

on index
   put federation_FetchRecentAtopia() into atopiaDomains  
   put "Recent Atopia Sites" & CR & CR & atopiaDomains into rosterText
   put roster_ConstructPageArray (rosterText) into pageArray
   transport_ReturnPageArray pageArray
end index

on author
   put rigFetchSegment(3, "") into authorName
   -- put "david-bovill" into authorName
   replace "-" with space in authorName
   --
   put author_ListRecentSites (authorName) into thisWeeksAuthorDomains
   put author_ConstructRecentPageArray (authorName, thisWeeksAuthorDomains) into pageArray
   --
   transport_ReturnPageArray pageArray
end author

