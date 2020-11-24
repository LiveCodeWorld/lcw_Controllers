script "today.lc"
getprop dep_StackNames
   return "lib_AtopiaTree,lib_Date,lib_Fedwiki,lib_FedwikiRoster,lib_PageArray,model_Atopia,model_Federation,model_Fedray,model_PageArray"
end dep_StackNames

on index
   federation_ReturnActivityRoster "Todays Activity", "1 day"
end index
