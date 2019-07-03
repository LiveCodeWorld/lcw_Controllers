script "recent_atopia.lc" with behavior "behavior_RigLocalOveride"
getprop dep_StackNames
    return "lib_Fedwiki,lib_FedwikiRoster,lib_Federation,model_PageArray"
end dep_StackNames

on index
   put federation_FetchRecentAtopia() into atopiaDomains  
   -- put atopia_FetchRoster ("c0de.academy") into atopiaDomains
   put roster_ConstructPageArray (atopiaDomains) into pageArray
   fedwiki_ReturnPageArray pageArray
end index
