script "federation.lc"
getprop dep_StackNames
   return "lib_AtopiaTree,lib_Date,lib_Fedwiki,lib_FedwikiRoster,lib_PageArray,model_Atopia,model_Federation,model_Fedray,model_PageArray"
end dep_StackNames

on index
   federation_ReturnActivityRoster "Recent Federation Activity", "1 week"
end index
