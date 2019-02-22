script "commons.lc"
getprop dep_StackNames
   return "lib_Fedwiki,lib_FedwikiRoster"
end dep_StackNames

on index
   put atopia_FetchRoster ("commons.world") into refTable
   put fedwiki_ConstructRosterPageArray (refTable) into pageArray
   fedwiki_ReturnPageArray pageArray
end index
