script "search.lc" with behavior "behavior_RigLocalOveride"
getprop dep_StackNames
   return "lib_Encoding,lib_Fedwiki,lib_GoogleCustomSearch,lib_PageArray,model_Secret"
end dep_StackNames

on index
   put cse_ConstructPostArray ("Federation", "wiki") into postArray
   cse_DeconstructPostArray postArray, cseName, googleQuery, pWord, cseOffset
   put cse_SearchAndConstructPageArray (googleQuery, pWord, cseOffset, cseName) into pageArray
   transport_ReturnPageArray pageArray
end index

on cse
   put transport_GetDroppedArray() into postArray
   --
   cse_DeconstructPostArray postArray, cseName, googleQuery, pWord, cseOffset
   put cse_SearchAndConstructPageArray (googleQuery, pWord, cseOffset, cseName) into pageArray
   --
   put json_FromArray (pageArray) into someJSON
   replace "\u0022" with quote in someJSON
   transport_ReturnJSON someJSON
end cse
