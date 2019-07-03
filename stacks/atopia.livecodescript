script "atopia.lc" with behavior "behavior_RigLocalOveride"
getprop dep_StackNames
    return "lib_Federation,lib_Fedwiki,lib_FedwikiRoster,lib_PageArray,model_Federation,model_PageArray"
end dep_StackNames

on index
   put federation_FetchRecentAtopia() into atopiaDomains  
   put "Recent Atopia Sites" & CR & CR & atopiaDomains into rosterText
   put roster_ConstructPageArray (rosterText) into pageArray
   fedwiki_ReturnPageArray pageArray
end index

on list
   put fedwiki_GetDroppedArray() into postArray
   put postArray ["outputType"] into outputType
   --
   put federation_FetchRecentAtopia () into wikiDomains
   switch outputType
      case "top"
         put url_ListTopDomains (wikiDomains) into wikiDomains
         break
      default
   end switch
   url_SortDomainIndex wikiDomains
   put fedwiki_MarkdownIndex (wikiDomains) into markdownIndex
   --
   put postArray ["pageSlug"] into templateSlug
   put postArray ["wikiDomain"] into templateDomain
   put postArray ["itemID"] into itemID
   --
   put pageArray_Fetch (templateDomain, templateSlug) into pageArray
   pageArray_SetItemText pageArray, itemID, markdownIndex
   pageArray_StripJournal pageArray
   pageArray_AddFork pageArray, "sites.fedwiki.org"
   --
   fedwiki_ReturnPageArray pageArray   
end list
