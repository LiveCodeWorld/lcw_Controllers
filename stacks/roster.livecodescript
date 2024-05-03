script "roster.lc"
getprop dep_StackNames
   return "lib_AtopiaTree,lib_Curly,lib_Date,lib_Fedwiki,lib_FedwikiCreate,lib_FedwikiRoster,lib_GoogleCustomSearch,lib_PageArray,lib_Transport,model_Atopia,model_AtopiaAuthors,model_Federation,model_Fedray,model_PageArray"
end dep_StackNames


--> Deps
-
function _DomainFromReferer requestArray
   put daemon_ReceivedHeader ("Referer", requestArray) into sReferer
   set the itemdelimiter to slash
   put item 3 of sReferer into wikiDomain
   return wikiDomain
end _DomainFromReferer

function daemon_ReceivedHeader sKey, requestArray
   put _ReceivedHeaderArray (requestArray) into receivedHeaderArray
   put word 1 to -1 of receivedHeaderArray [sKey] into sValue
   return sValue
end daemon_ReceivedHeader
   
private function _ReceivedHeaderArray requestArray
   put requestArray ["receivedHeaders"] into receivedHeaderArray
   split receivedHeaderArray with CR and ":"
   return receivedHeaderArray
end _ReceivedHeaderArray


--> Roster | Update
-
on dynadot_SitesIndex
   /*
   put postArray ["wikiDomain"] into wikiDomain
   if wikiDomain is empty then put _RefererDomain() into wikiDomain
   federation_ReturnSitesPageArray wikiDomain, pageTitle
   put wikiPage_FilteredDomainList (filterWord, domainIndexTitle) into pageArray
   put roster_ConstructActivityPage (wikiDomain, rosterDomains, templatePageArray) into pageArray
   */
   
   put transport_GetDroppedArray() into postArray
   put postArray ["pageTitle"] into pageTitle
   if pageTitle is empty then put "Wiki Sites" into pageTitle
   put postArray ["filterWord"] into filterWord
   
   put dynadot_ListDomainNames() into wikiDomains
   if filterWord is not empty then
      filter wikiDomains with filterWord
   end if
   
   put "Here is a list of domain names hosted on Dynadot:"  into firstPara
   put wikiPage_CreateMissingSites (pageTitle, wikiDomains, firstPara) into pageArray
   -- put wikiPage_FilteredSites (pageTitle, wikiDomains, firstPara) into pageArray
   --
   transport_ReturnPageArray pageArray
end dynadot_SitesIndex

on update_RosterPage requestArray
   transport_SetInfo wikiDomain, pageSlug, pageTitle
   put the result into postArray
   put postArray ["filterWord"] into filterWord
   if filterWord is empty then
      put _DomainFromReferer (requestArray) into wikiDomain
      set the itemdelimiter to "."
      get item -2 to -1 of wikiDomain
      --
      put "*" & it into filterWord
      put it && "Sites" into domainIndexTitle
      replace "." with space in domainIndexTitle
      put text_InitialCaps (domainIndexTitle) into domainIndexTitle
   end if
   --
   put wikiPage_FilteredDomainList (filterWord, domainIndexTitle) into pageArray
   -- get roster_ConstructActivityPage (wikiDomain, rosterDomains, templatePageArray)
   transport_ReturnPageArray pageArray
end update_RosterPage

on update 
   -- update a roster
   _SetPostVars itemID, domainFilter, templateSlug, templateDomain, minPageNum, outputType
   --
   put roster_FetchUpdatedPageArray (domainFilter, templateDomain, templateSlug, pItemID) into pageArray
   transport_ReturnPageArray pageArray   
end update

function roster_FetchUpdatedPageArray domainFilter, templateDomain, templateSlug, pItemID
   if domainFilter = "top" then
      put atopia_FetchRoster() into domainNames
      put url_ListTopDomains (domainNames) into domainNames
   else
      put atopia_FetchRoster (domainFilter, false) into domainNames
   end if
   --
   put pageArray_Fetch (templateDomain, templateSlug) into pageArray
   if pageArray is empty then
      put merge ("Could not find page '[[templateSlug]]' of wiki '[[templateDomain]]'.") into someText
      put pageArray_Construct ("Missing Page!", someText) into pageArray
      transport_ReturnPageArray pageArray
      exit to top
   end if
   
   put fedwiki_ConstructTitle (templateSlug) into pageTitle
   put pageTitle & CR & CR & domainNames into rosterText
   --
   if pItemID is empty then
      put pageArray_FindItemType ("roster", pageArray) into itemNum
      put rosterText into pageArray ["story"][itemNum]["text"]
   else
      pageArray_SetItemText pageArray, pItemID, rosterText
   end if
   --
   pageArray_StripJournal pageArray
   return pageArray
end roster_FetchUpdatedPageArray

on index 
   put atopia_FetchRoster() into wikiDomains
   get roster_ConstructPageArray (wikiDomains)
   transport_ReturnPageArray it
end index

on sites
   _SetFormTitleDomain wikiDomain, pageTitle
   federation_ReturnSitesPageArray wikiDomain, pageTitle
end sites

on atopiaSites
   _SetFormTitleDomain wikiDomain, pageTitle
   atopia_ReturnSitesPageArray wikiDomain, pageTitle
end atopiaSites

on transportSites
   /*
   put "http://rest.livecode.world/festival" into tURL
   put "Festival Jam Sites" into pageTitle
   put "festivaljam.org" into wikiDomain
   */
   --
   put transport_GetDroppedArray() into postArray
   put postArray ["transport"] into tURL
   put postArray ["pageTitle"] into pageTitle
   put postArray ["wikiDomain"] into wikiDomain
   if wikiDomain is empty then
      set the itemdelimiter to slash
      put item 3 of $HTTP_REFERER into wikiDomain
   end if
   --
   put url tURL into pageJSON
   put json_ToArray (pageJSON) into pageArray
   put pageArray_GetFirstRoster (pageArray) into rosterDomains
   roster_StripHeader rosterDomains
   --
   put roster_ConstructSitesPageArray (wikiDomain, rosterDomains, pageTitle) into pageArray
   --
   transport_ReturnPageArray pageArray
end transportSites

on subdomain
   transport_SetFormSlugDomain wikiDomain, pageSlug
   put the result into postArray
   put postArray ["sincePeriod"] into sincePeriod
   put postArray ["authorName"] into authorName
   /*
   put "author.fedwiki.org" into wikiDomain
   put "David Bovill" into authorName
   put "david-bovill-sites" into pageSlug
   */
   
   put pageArray_Fetch (wikiDomain, pageSlug) into pageArray
   put author_ListFedrayDomains (authorName, sincePeriod) into wikiDomains
   --
   put "List of sites" into sectionTitle
   put fedwiki_MarkdownIndex (wikiDomains) into markdownIndex
   --
   pageArray_EditSectionTitleText pageArray, sectionTitle, markdownIndex
   put authorName & CR&CR & wikiDomains into rosterText
   pageArray_SetFirstItem pageArray, "roster", rosterText
   --
   transport_ReturnPageArray pageArray
end subdomain

on federation
   put transport_GetFormDomain() into wikiDomain
   -- put "voz.money" into wikiDomain
   --
   put fedray_FetchDomains (wikiDomain) into rosterDomains
   put roster_ConstructSitesPageArray (wikiDomain, rosterDomains, pageTitle) into pageArray
   --
   transport_ReturnPageArray pageArray
end federation

on author
   put rigFetchSegment(3, "") into authorName
   replace "-" with space in authorName
   -- put "david bovill" into authorName
   --
   put author_FetchRosterSites (authorName, "(sites)") into wikiDomains
   -- put author_FetchModelDomains(authorName) into wikiDomains
   
   put roster_ConstructPageArray (wikiDomains) into pageArray
   put pageArray_Construct ("Test", authorName) into pageArray
   --
   transport_ReturnPageArray pageArray
end author

on tsv
   put transport_GetDroppedArray() into postArray
   put postArray ["wikiDomain"] into wikiDomain
   put postArray ["minPageNum"] into minPageNum
   put postArray ["cseID"] into cseID
   --
   -- put atopia_ListWelcomeFolders (wikiDomain) into atopiaDomains
   put federation_ListDomains (wikiDomain) into wikiDomains
   --
   put cse_ConstructTSV (wikiDomains, cseID) into federationTSV
   --
   put pageArray_Construct ("Federation TSV", federationTSV) into pageArray
   transport_ReturnPageArray pageArray
end tsv

on cat
   put transport_GetDroppedArray() into postArray
   put postArray ["pageSlug"] into templateSlug
   put postArray ["wikiDomain"] into templateDomain
   
   put pageArray_Fetch (templateDomain, templateSlug) into pageArray
   put roster_PagefoldConstruct (pageArray) into rosterText
   --
   put "An automatically created roster. Created by [[Roster Maker]]." into pageDescription
   put fedwiki_CreateMarkdownPageArray ("Categorised Roster", pageDescription) into pageArray
   pageArray_AddRoster pageArray, rosterText
   --
   transport_ReturnPageArray pageArray   
end cat

on refs
   put transport_GetDroppedArray() into postArray
   --
   put postArray ["domainFilter"] into domainFilter
   put postArray ["pageSlug"] into templateSlug
   put postArray ["wikiDomain"] into templateDomain
   --
   put atopia_FetchRoster (domainFilter) into rosterDomains
   put roster_TidyPageFoldMaker (templateDomain, templateSlug, rosterDomains) into fromPageArray
   --
   transport_ReturnPageArray fromPageArray   
end refs

on list
   put transport_GetFormDomain() into wikiDomain
   put transport_GetDroppedArray() into postArray
   put postArray ["pageSlug"] into pageSlug
   --
   put postArray ["itemID"] into itemID
   put postArray ["outputType"] into outputType
   --
   switch outputType
      case "top"
         put atopia_FetchRoster (domainFilter) into filteredAtopiaDomains
         put url_ListTopDomains (filteredAtopiaDomains) into wikiDomains
         break
         -- case "refs"
      default
         put atopia_FetchRoster (domainFilter) into wikiDomains
   end switch
   --
   url_SortDomainIndex wikiDomains
   put fedwiki_MarkdownIndex (wikiDomains) into markdownIndex
   put pageArray_Fetch (templateDomain, templateSlug) into pageArray
   pageArray_SetItemText pageArray, itemID, markdownIndex
   pageArray_StripJournal pageArray
   pageArray_AddFork pageArray, "sites.fedwiki.org"
   --
   transport_ReturnPageArray pageArray   
end list

on domain
   put rigFetchSegment(3, "") into topDomain
   --
   put atopia_FetchRoster (topDomain) into rosterText
   put roster_ConstructPageArray (rosterText) into pageArray
   transport_ReturnPageArray pageArray
end domain

on activity
   -- used by form for creating a roster-page
   put transport_GetDroppedArray() into postArray
   put postArray ["wikiDomain"] into wikiDomain
   put _CreateActivityPage (wikiDomain) into pageArray
   transport_ReturnPageArray pageArray
end activity


--> Private
-
private function _RefererDomain
   set the itemdelimiter to slash
   put item 3 of $HTTP_REFERER into wikiDomain
   return wikiDomain
end _RefererDomain

private command _SetFormTitleDomain @wikiDomain, @pageTitle
   put transport_GetDroppedArray() into postArray
   put postArray ["wikiDomain"] into wikiDomain
   if wikiDomain is empty then put _RefererDomain() into wikiDomain

   put postArray ["pageTitle"] into pageTitle
   return postArray
end _SetFormTitleDomain

private function _CreateActivityPage wikiDomain
   -- used by "roster.lc" (nothing else yet)
   put atopia_FetchRoster (wikiDomain, false) into rosterDomains
   put pageArray_Fetch ("roster.fedwiki.org", "roster-template") into templatePageArray
   --
   put roster_ConstructActivityPage (wikiDomain, rosterDomains, templatePageArray) into pageArray
   return pageArray
end _CreateActivityPage


private command _SetPostVars @itemID, @domainFilter, @pageSlug, @wikiDomain, @minPageNum, @outputType
   put transport_GetDroppedArray() into postArray
   --
   put postArray ["itemID"] into itemID
   put postArray ["domainFilter"] into domainFilter
   put postArray ["pageSlug"] into pageSlug
   put postArray ["wikiDomain"] into wikiDomain
   put postArray ["minPageNum"] into minPageNum
   put postArray ["outputType"] into outputType
end _SetPostVars
