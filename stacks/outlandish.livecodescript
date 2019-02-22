script "outlandish.lc" with behavior "behavior_RigLocalOveride"
getprop dep_StackNames
   return "lib_Fedwiki,lib_FedwikiRoster"
end dep_StackNames

on index
   put atopia_FetchRoster ("outlandish.academy") into refTable
   put fedwiki_ConstructRosterPageArray (refTable) into pageArray
   fedwiki_ReturnPageArray pageArray
end index
