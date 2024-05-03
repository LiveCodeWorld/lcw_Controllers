script "register.lc"
getprop dep_StackNames
   return "lib_Fedwiki,lib_FedwikiRoster,lib_PageArray,lib_Transport,model_PageArray"
end dep_StackNames

on index
   _SetParams wikiToAdd, rosterName, templateDomain
   put transport_FetchRosterPageArray (rosterName, wikiToAdd, templateDomain) into pageArray
   --
   transport_StorePageArray pageArray
   put the result into jsonPath
   put pageArray_Construct ("Activity", jsonPath) into activityPageArray
   --
   transport_ReturnPageArray pageArray
end index

on clearRoster
   _SetParams wikiToAdd, rosterName, templateDomain
   put transport_FetchEmptyRosterPageArray (rosterName, templateDomain) into pageArray
   --
   transport_StorePageArray pageArray
   put the result into jsonPath
   put pageArray_Construct ("Activity", jsonPath) into activityPageArray
   --
   transport_ReturnPageArray activityPageArray
end clearRoster

private command _SetParams @wikiToAdd, @rosterName, @templateDomain
   /*
   put "One World Sites" into rosterName
   put "david.dojo.fed.wiki" into wikiToAdd
   put empty into templateDomain
   return true
   */
   
   put transport_GetDroppedArray() into postArray
   put postArray ["rosterName"] into rosterName
   put postArray ["templateDomain"] into templateDomain
   --
   put postArray ["wikiDomain"] into wikiToAdd
   if wikiToAdd is empty then
      set the itemdelimiter to slash
      put item 3 of $HTTP_REFERER into wikiToAdd
   end if
end _SetParams
