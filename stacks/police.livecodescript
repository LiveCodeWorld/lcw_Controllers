script "police.lc"
getprop dep_StackNames
   return "lib_Fedwiki,lib_FedwikiRoster,lib_PageArray,model_Fedwiki,model_Fedray,model_PageArray"
end dep_StackNames

on index
   roster_ReturnPageArray "dojo.fed.wiki", "Challenges of Policing"
end index

on dojo
   roster_ReturnPageArray "dojo.fed.wiki"
end dojo


