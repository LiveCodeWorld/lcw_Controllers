script "google.lc" with behavior "behavior_RigLocalOveride"
getprop dep_StackNames
   return "lib_Fedwiki,lib_Google,lib_PageArray,model_PageArray"
end dep_StackNames

on index
   put transport_DroppedUrl() into googleURL
   put google_ConstructFedwikiImagePageArray (googleURL) into fedwikiPageArray
   transport_ReturnPageArray fedwikiPageArray
end index
