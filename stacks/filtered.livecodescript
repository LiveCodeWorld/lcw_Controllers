script "filtered.lc"
getprop dep_StackNames
   return "lib_AtopiaTree,lib_Federation,lib_Fedwiki,lib_FedwikiRoster,lib_PageArray,model_Federation,model_PageArray"
end dep_StackNames

on index
   put federation_RecentWithoutAtopiaDomains() into withoutAtopiaDomains
   put "Filtered Federation Activity" & CR & CR before withoutAtopiaDomains
   put roster_ConstructPageArray (withoutAtopiaDomains) into pageArray
   transport_ReturnPageArray pageArray
end index
