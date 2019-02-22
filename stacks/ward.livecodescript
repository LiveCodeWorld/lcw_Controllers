script "ward.lc" with behavior "behavior_RigLocalOveride"
getprop dep_StackNames
   return "lib_Fedwiki,lib_AtopiaFetch"
end dep_StackNames

on index
   put federation_FetchDomains ("fed.wiki") into refTable
   put fedwiki_ConstructRosterPageArray (refTable) into pageArray
   fedwiki_ReturnPageArray pageArray
end index
