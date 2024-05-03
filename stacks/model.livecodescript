script "model.lc"
getprop dep_StackNames
   return "lib_Fedwiki,lib_PageArray,lib_Transport,model_Atopia,model_PageArray"
end dep_StackNames

on index
   put pageArray_Construct ("writeModel", "Atopia Model") into rPageArray
   transport_ReturnPageArray rPageArray
end index
