script "today.lc"
getprop dep_StackNames
   return "lib_AtopiaTree,lib_Date,lib_Fedwiki,lib_FedwikiRoster,lib_PageArray,lib_Transport,model_Atopia,model_Federation,model_PageArray,model_Transport"
end dep_StackNames

on index
   federation_ReturnActivityRoster "Todays Activity", "1 day"
end index

on archive
   put transport_GetFormDomain() into wikiDomain
   --
   put pageArray_Fetch (wikiDomain, "today") into pageArray
   put _GetPageTitle() into dayTitle
   --
   pageArray_Rename pageArray, dayTitle
   --
   -- here we could store dayTitle page and return blank Today page.
   transport_ReturnPageArray pageArray
end archive

private function _GetPageTitle
   put the long date into dayTitle
   delete item 1 of dayTitle
   return dayTitle
end _GetPageTitle
