script "author.lc"
getprop dep_StackNames
    return "lib_AtopiaAuthorCreate,lib_Curly,lib_Fedray,lib_Fedwiki,lib_PageArray,model_AtopiaAuthors,model_Federation,model_Fedray,model_PageArray,model_WikiPage"
end dep_StackNames

on index
   put transport_GetDroppedArray() into dArray
   put dArray ["authorName"] into authorName
   put dArray ["sincePeriod"] into sincePeriod
   put dArray ["authorTemplate"] into authorTemplate
   --
   put author_FetchUpdatedPageArray (authorName, sincePeriod, authorTemplate) into pageArray
   --
   transport_ReturnPageArray pageArray
end index
