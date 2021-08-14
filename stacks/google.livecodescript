script "google.lc" with behavior "behavior_RigLocalOveride"
getprop dep_StackNames
   return "lib_Fedwiki,lib_Google,lib_PageArray,model_PageArray"
end dep_StackNames

on index
   put fedwiki_GetDroppedUrl() into googleURL
   put google_ConstructFedwikiImagePageArray (googleURL) into fedwikiPageArray
   fedwiki_ReturnPageArray fedwikiPageArray
end index
