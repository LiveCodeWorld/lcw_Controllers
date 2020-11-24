script "testing.lc"
getprop dep_StackNames
   return "lib_AtopiaFetch,lib_Fedwiki,lib_PageArray,lib_URL"
end dep_StackNames

on index
   put "voz.money" into wikiDomain
   get fedwiki_FetchPluginJSON ("federation-model", "roster.fedwiki.org")
   put json_ToArray (it) into fedray
   put keys (fedray) into wikiDomains
   put pageArray_Construct ("Money", wikiDomains) into pageArray
   fedwiki_ReturnPageArray pageArray
end index

on good
   put fedray_FetchDomains ("voz.money") into fedrayDomains
   --
   put pageArray_Construct ("Money", fedrayDomains) into pageArray
   fedwiki_ReturnPageArray pageArray
end good

on bad
   put fedray_FetchModel() into fedray
   --
   put keys (fedray) into fedrayDomains
   url_SortDomainIndex fedrayDomains
   --
   put pageArray_Construct ("Money", fedrayDomains) into pageArray
   fedwiki_ReturnPageArray pageArray
end bad
