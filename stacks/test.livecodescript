script "test.lc" with behavior "behavior_RigLocalOveride"
getprop dep_StackNames
   return "lib_Fedwiki,lib_PageArray,model_Federation"
end dep_StackNames

on index
   put fedray_FetchDomains ("voz.money") into rosterDomains
   put pageArray_Construct ("Money", rosterDomains) into pageArray
   transport_ReturnPageArray pageArray
end index

