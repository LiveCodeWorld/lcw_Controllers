script "proto.lc"
getprop dep_StackNames
   return "lib_Fedwiki,lib_FedwikiRoster,lib_PageArray"
end dep_StackNames

on index
   put roster_FetchLivePageArray ("proto.institute") into pageArray
   fedwiki_ReturnPageArray pageArray
end index
