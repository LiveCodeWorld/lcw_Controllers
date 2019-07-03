script "david.lc" with behavior "behavior_RigLocalOveride"
getprop dep_StackNames
    return "lib_Fedwiki,lib_PageArray,lib_Federation,model_Federation,lib_FedwikiRoster"
end dep_StackNames

on index
   put federation_FetchAuthorDomains ("David Bovill") into domainNames
   put roster_ConstructPageArray (domainNames) into pageArray
   fedwiki_ReturnPageArray pageArray
end index
