script "recent.lc" with behavior "behavior_RigLocalOveride"
getprop dep_StackNames
   return "lib_Fedwiki,lib_FedwikiRoster,lib_AtopiaFetch"
end dep_StackNames

on index
   put federation_FetchMyRecentOther (false) into domainNames
   put "Recent Federation Activity" & CR & CR & domainNames into strippedRosterText
   put fedwiki_ConstructRosterPageArray (strippedRosterText) into pageArray
   fedwiki_ReturnPageArray pageArray
end index
