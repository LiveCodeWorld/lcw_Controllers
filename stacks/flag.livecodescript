script "flag.lc"
getprop dep_StackNames
   -- return "lib_Curly,lib_Fedwiki,lib_PageArray,model_PageArray"
   return "lib_Curly,lib_Fedwiki,lib_MediaWiki,lib_PageArray,lib_WikiPageArray,model_PageArray"
end dep_StackNames

on index
   fedwiki_SetDroppedFaviconInfo pageSlug, wikiDomain
   --
   put fedwiki_SlugToTitle (pageSlug) into pageTitle
   mediawiki_NormaliseTitle pageSlug, mediaWikiTitle, pageID
   
   put pageArray_FetchTemplate ("fedwiki.org", "future-dialogue-template", "Edit Wiki Page") into pageArray
   --
   put pageTitle into curlyData ["all"]["New Page Title"]
   put mediaWikiTitle into curlyData ["all"]["Wikipedia Title"]
   put pageSlug into curlyData ["all"]["originalSlug"]
   put wikiDomain into curlyData ["all"]["wikiDomain"]
   --
   curly_MergePageArray pageArray, curlyData
   --
   fedwiki_ReturnPageArray pageArray
end index

on editPageTitle
   -- posted from form on "Future Dialoge Template" wiki-page
   put fedwiki_GetDroppedArray() into postedArray
   --
   put postedArray ["title"] into newPageTitle
   put postedArray ["originalSlug"] into originalSlug
   put postedArray ["wikiDomain"] into wikiDomain
   
   if originalSlug is empty then
      put merge ("This transporter cannot be used for this operation!") into errorText
      fedwiki_ExitAndReturnError errorText, "Not a Fedwiki URL"
   end if
   --
   put pageArray_Fetch (wikiDomain, originalSlug, true) into pageArray
   pageArray_Rename pageArray, newPageTitle
   put originalSlug && wikiDomain into someMarkdown
   pageArray_AddMarkdown pageArray, someMarkdown
   --
   fedwiki_ReturnPageArray pageArray
end editPageTitle
