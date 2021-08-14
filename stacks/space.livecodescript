script "space.lc"
getprop dep_StackNames
    return "lib_AtopiaTree,lib_Fedwiki,lib_FedwikiRoster,lib_FedwikiSitemap,lib_PageArray,model_Fedwiki,model_PageArray"
end dep_StackNames

on index
   atopia_ReturnRoster "spacenet.work"
end index
