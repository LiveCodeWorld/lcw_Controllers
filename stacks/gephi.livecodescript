﻿script "gephi.lc"
getprop dep_StackNames
   return "lib_Fedwiki,model_Fedwiki,lib_PageArray,model_PageArray,lib_FedwikiRoster,lib_Federation,lib_Gephi"
end dep_StackNames

on index
   local pNotTheseSlugs
   --
   put pageArray_Fetch (wikiDomain, pageSlug) into pageArray
   put pageArray_GetPageLinkSlugs (pageArray) into pSlugs
   
   put gephi_ConstructCsv (pSlugs, wikiDomain) into gephiCSV
   --
   put "Here is the CSV generated from the links on the page you dropped ready for inport into [[gephi]]:" into someText
   put fedwiki_ConstructNewPageArray ("Gephi CSV", someText) into pageArray
   pageArray_AddCode pageArray, gephiCSV
   --
   transport_ReturnPageArray pageArray
end index

on tables
   local pNotTheseSlugs
   transport_SetInfo wikiDomain, pageSlug, pageTitle
   
   put pageArray_Fetch (wikiDomain, pageSlug) into pageArray
   put pageArray_GetPageLinkSlugs (pageArray) into pSlugs
   --
   put gephi_ConstructTableArray (pSlugs, wikiDomain) into gephiTableArray
   put gephiTableArray ["csvLines"] into csvLines
   put gephiTableArray ["nodeTableLines"] into nodeTableLines
   --
   put "Here are the tables generated from the links on the page you dropped ready for inport into [[gephi]]:" into someText
   put fedwiki_ConstructNewPageArray ("Gephi CSV", someText) into pageArray
   
   pageArray_AddCode pageArray, csvLines
   pageArray_AddCode pageArray, nodeTableLines
   --
   transport_ReturnPageArray pageArray
end tables

on lineup
   local pNotTheseSlugs
   put transport_DroppedUrl ($_POST_RAW) into droppedURL
   
   put fedwiki_ConstructUrlArray (droppedURL) into urlArray
   
   
   put fedwiki_ConstructNewPageArray ("Gephi CSV", someJSON) into pageArray
   transport_ReturnPageArray pageArray
end lineup

