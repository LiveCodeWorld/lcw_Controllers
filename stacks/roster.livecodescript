script "roster.lc" with behavior "behavior_RigLocalOveride"
getprop dep_StackNames
    return "lib_Fedwiki,lib_FedwikiRoster,lib_FedwikiCreate,lib_GoogleCustomSearch"
end dep_StackNames

on index topDomain
   -- fetch all Atopia domains
   put atopia_FetchStoredDomains() into rosterText
   put fedwiki_ConstructRosterPageArray (rosterText) into pageArray
   fedwiki_ReturnPageArray pageArray
end index

on advanced
   if the environment = "server" then
      put fedwiki_GetDroppedArray() into postArray
   else
      put empty into postArray ["domainFilter"]
      put 200 into postArray ["minPageNum"]
   end if
   
   put postArray ["domainFilter"] into domainFilter
   put postArray ["minPageNum"] into minPageNum
   --
   put atopia_FetchStoredDomains (domainFilter, false, minPageNum) into someDomains
   put cse_ConstructTSV (someDomains) into federationTSV
   --
   put fedwiki_ConstructErrorJSON (federationTSV, "Federation TSV") into errorJSON
   fedwiki_ReturnJSON errorJSON
end advanced

on cat
   if the environment = "server" then
      put fedwiki_GetDroppedArray() into postArray
   else
      put "livecode-site-refs" into postArray ["pageSlug"]
      put "livecode.world" into postArray ["wikiDomain"]
   end if
   put postArray ["pageSlug"] into templateSlug
   put postArray ["wikiDomain"] into templateDomain
   
   put fedwiki_FetchPageArray (templateDomain, templateSlug) into pageArray
   put fedwiki_ConstructPagefoldRoster (pageArray) into rosterText
   --
   put "An automatically created roster. Created by [[Roster Maker]]." into pageDescription
   put fedwiki_CreateMarkdownPageArray ("Categorised Roster", pageDescription) into pageArray
   fedwiki_AddRosterToPageArray pageArray, rosterText
   --
   fedwiki_ReturnPageArray pageArray   
end cat

on refs
   if the environment = "server" then
      put fedwiki_GetDroppedArray() into postArray
   else
      put "livecode.world" into postArray ["domainFilter"]
      put "livecode-site-refs" into postArray ["pageSlug"]
      put "livecode.world" into postArray ["wikiDomain"]
   end if
   
   put postArray ["domainFilter"] into domainFilter
   put postArray ["pageSlug"] into templateSlug
   put postArray ["wikiDomain"] into templateDomain
   --
   put atopia_FetchStoredDomains (domainFilter) into rosterDomains
   put fedwiki_TidyRefPageRoster (templateDomain, templateSlug, rosterDomains) into fromPageArray
   --
   fedwiki_ReturnPageArray fromPageArray   
end refs

on subdomain
   put fedwiki_GetDroppedArray() into postArray
   put postArray ["itemID"] into itemID
   put postArray ["domainFilter"] into domainFilter
   put postArray ["pageSlug"] into templateSlug
   put postArray ["wikiDomain"] into templateDomain
   put postArray ["outputType"] into outputType
   --
   put atopia_FetchStoredDomains (domainFilter) into rosterDomainText
   --
   switch outputType
      case "refs"
         
         break
      default
         put fedwiki_ConstructMarkdownIndex (rosterDomainText) into markdownIndex
         put fedwiki_FetchPageArray (templateDomain, templateSlug) into pageArray
         fedwiki_SetStoryItemText pageArray, itemID, markdownIndex
         fedwiki_StripJournalToCreate pageArray
   end switch
   --
   fedwiki_ReturnPageArray pageArray   
end subdomain

on atopia_merge
   if the environment = "server" then
      put fedwiki_GetDroppedArray() into postArray
   else
      put _ConstructPostArray ("741a0fcdd3ff76b2", "livecode.world", "roster-maker", "transport.fedwiki.org") into postArray
   end if
   --
   _DeconstractPostArray postArray, itemID, domainFilter, templateSlug, templateDomain, minPageNum
   put atopia_FetchStoredDomains (domainFilter) into rosterDomainText
   put fedwiki_UpdateRosterPageArray (templateDomain, templateSlug, itemID, rosterDomainText) into pageArray
   --
   fedwiki_ReturnPageArray pageArray   
end atopia_merge

on domain topDomain
   -- roster can;t use these url's :(
   
   if the environment = "server" then
      put rigFetchSegment(3, "") into topDomain
   else
      put "" into topDomain
   end if
   --
   put atopia_FetchStoredDomains (topDomain) into rosterText
   put fedwiki_ConstructRosterPageArray (rosterText) into pageArray
   fedwiki_ReturnPageArray pageArray
end domain

function _ConstructPostArray itemID, domainFilter, pageSlug, wikiDomain, minPageNum
   put itemID into postArray ["itemID"]
   put domainFilter into postArray ["domainFilter"]
   put pageSlug into postArray ["pageSlug"]
   put wikiDomain into postArray ["wikiDomain"]
   put minPageNum into postArray ["minPageNum"]
   return postArray
end _ConstructPostArray

command _DeconstractPostArray postArray, @itemID, @domainFilter, @pageSlug, @wikiDomain, @minPageNum
   put postArray ["itemID"] into itemID
   put postArray ["domainFilter"] into domainFilter
   put postArray ["pageSlug"] into pageSlug
   put postArray ["wikiDomain"] into wikiDomain
   put postArray ["minPageNum"] into minPageNum
end _DeconstractPostArray
