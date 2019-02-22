script "filtered_activity.lc" with behavior "behavior_RigLocalOveride"
getprop dep_StackNames
   return "lib_Fedwiki,lib_FedwikiRoster,lib_FedwikiCreate"
end dep_StackNames

on index
   put fedwiki_FetchFilteredFederationActivity ("server.fedwiki.org", "atopia-domain-index", "741a0fcdd3ff76b2") into pageArray
   fedwiki_ReturnPageArray pageArray
end index
