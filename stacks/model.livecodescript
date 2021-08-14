script "model.lc"
getprop dep_StackNames
   return "lib_Fedwiki,lib_PageArray,lib_Transport,model_Atopia,model_PageArray"
end dep_StackNames

on index
   put pageArray_Construct ("writeModel", "Atopia Model") into rPageArray
   fedwiki_ReturnPageArray rPageArray
   /*
   put transport_GetModelFolder() into modelFolder
   put file_ListShort (modelFolder) into shortModelFiles
   put shortModelFiles
   */
end index

function file_ListShort someFolder, pShowInvisible
   if there is not a folder someFolder then return empty
   put files (someFolder) into shortFiles
   if pShowInvisible is not true then filter shortFiles without ".*"
   return shortFiles
end file_ListShort




