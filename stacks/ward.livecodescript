script "ward.lc" with behavior "behavior_RigLocalOveride"
getprop dep_StackNames
    return "lib_Fedwiki,lib_PageArray,model_PageArray,lib_FedwikiRoster"
end dep_StackNames

on index
   put federation_FetchAuthorDomains ("Ward Cunningham") into domainNames
   put roster_ConstructPageArray (domainNames) into pageArray
   put pageArray_Construct (pageTitle, pSomeText, pSourceArray)
   transport_ReturnPageArray pageArray
end index
