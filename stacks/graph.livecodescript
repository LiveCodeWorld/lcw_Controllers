script "graph.lc"
getprop dep_StackNames
   return "lib_Fedwiki,lib_PageArray,model_Help,model_HkeyLine,model_PageArray"
end dep_StackNames

on index
   put "M transport_SetModel" into hKey
   put hKey
end index

on viz
   put rigFetchSegment(3, "") into hName
   put help_FetchHandlerPageArray (hName) into pageArray
   put pageArray_GetGraph (pageArray) into dotText
   put dotText
end viz

