script "c0de.lc"
getprop dep_StackNames
    return "lib_Fedwiki,lib_PageArray,model_PageArray,lib_FedwikiRoster,lib_Federation"
end dep_StackNames

on index
   put atopia_FetchRoster ("c0de.academy") into refTable
   put roster_ConstructPageArray (refTable) into pageArray
   fedwiki_ReturnPageArray pageArray
end index
