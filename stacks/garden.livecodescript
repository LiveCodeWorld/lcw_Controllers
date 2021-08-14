script "garden.lc"
getprop dep_StackNames
   return "lib_Fedwiki,lib_FedwikiRoster,lib_PageArray,model_PageArray"
end dep_StackNames

on index
   put roster_FetchLivePageArray ("democracy.garden") into pageArray
   fedwiki_ReturnPageArray pageArray
end index
