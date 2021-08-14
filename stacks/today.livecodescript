script "today.lc"
getprop dep_StackNames
   return "lib_AtopiaTree,lib_Date,lib_Fedwiki,lib_FedwikiRoster,lib_PageArray,lib_Transport,model_Atopia,model_Federation,model_Fedray,model_PageArray"
end dep_StackNames

on index
   federation_ReturnActivityRoster "Todays Activity", "1 day"
end index

on archive
   put transport_GetFormDomain() into wikiDomain
   --
   put pageArray_Fetch (wikiDomain, "today") into pageArray
   put pageArray_GetLastEdit (pageArray) into dayTitle
   convert dayTitle to long date
   delete item 1 of dayTitle
   --
   pageArray_Rename pageArray, dayTitle
   --
   -- here we could store dayTitle page and return blank Today page.
   fedwiki_ReturnPageArray pageArray
end archive

function pageArray_GetLastEdit pageArray
   return the seconds
end pageArray_GetLastEdit
