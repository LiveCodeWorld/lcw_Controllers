script "mediagarden.lc"
getprop dep_StackNames
   return "lib_Fedwiki,lib_FedwikiRoster,lib_PageArray,model_Fedray,model_PageArray,model_Transport"
end dep_StackNames

on index
   roster_ReturnPageArray "mediagarden.org"
end index
