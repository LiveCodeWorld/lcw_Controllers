script "dojo.lc"
getprop dep_StackNames
   return "lib_AtopiaTree,lib_Fedwiki,lib_FedwikiRoster,lib_FedwikiSitemap,lib_PageArray,model_Federation,model_Fedray,model_Fedwiki,model_PageArray"
end dep_StackNames

on index
   roster_ReturnAtopiaPageArray "dojo.fed.wiki"
end index
