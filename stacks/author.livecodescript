script "author.lc"
getprop dep_StackNames
    return "lib_AtopiaAuthorCreate,lib_Curly,lib_Fedray,lib_Fedwiki,lib_PageArray,model_AtopiaAuthors,model_Federation,model_Fedray,model_PageArray,model_WikiPage"
end dep_StackNames

on index
   put fedwiki_GetDroppedArray() into dArray
   put dArray ["authorName"] into authorName
   put dArray ["sincePeriod"] into sincePeriod
   put dArray ["domainSlug"] into domainSlug
   --
   put author_FetchUpdatedPageArray (authorName, sincePeriod, domainSlug) into pageArray
   --
   fedwiki_ReturnPageArray pageArray
end index

on test
   put "David Bovill" into authorName
   put "1 week" into sincePeriod
   put "author.fedwiki.org/david-bovill-recent-sites" into domainSlug
   
   put author_FetchUpdatedPageArray (authorName, sincePeriod, domainSlug) into pageArray
   --
   fedwiki_ReturnPageArray pageArray
end test
