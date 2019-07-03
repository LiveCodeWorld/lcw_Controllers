script "recent.lc" with behavior "behavior_RigLocalOveride"
getprop dep_StackNames
   return "lib_Fedwiki,lib_FedwikiRoster,lib_PageArray,model_Federation,model_PageArray"
end dep_StackNames

on index
   put federation_FetchLiveRecentDomains() into domainNames
   put "Recent Federation Activity" & CR & CR & domainNames into strippedRosterText
   put roster_ConstructPageArray (strippedRosterText) into pageArray
   fedwiki_ReturnPageArray pageArray
end index
