script "flag.lc"
getprop dep_StackNames
    return "lib_Curly,lib_Fedwiki,lib_MediaWiki,lib_PageArray,lib_WikiPageArray,model_PageArray"
end dep_StackNames

on index
   transport_SetDroppedFaviconInfo pageSlug, wikiDomain
   --
   put fedwiki_SlugToTitle (pageSlug) into pageTitle
   put wikiPage_Future (pageSlug, wikiDomain) into pageArray
   --
   transport_ReturnPageArray pageArray
end index

on editPageTitle
   -- posted from form on "Future Dialoge Template" wiki-page
   put transport_GetDroppedArray() into postedArray
   --
   put postedArray ["title"] into newPageTitle
   put postedArray ["originalSlug"] into originalSlug
   put postedArray ["wikiDomain"] into wikiDomain
   
   if originalSlug is empty then
      put merge ("This transporter cannot be used for this operation!") into errorText
      transport_ExitAndReturnError errorText, "Not a Fedwiki URL"
   end if
   --
   put pageArray_Fetch (wikiDomain, originalSlug, true) into pageArray
   pageArray_Rename pageArray, newPageTitle
   --
   transport_ReturnPageArray pageArray
end editPageTitle
