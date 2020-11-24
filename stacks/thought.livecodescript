script "thought.lc"
getprop dep_StackNames
   return "lib_Fedwiki,lib_FedwikiRoster,lib_PageArray,model_Fedray,model_Fedwiki,model_PageArray"
end dep_StackNames

on index
   roster_ReturnPageArray "thought.garden"
end index
