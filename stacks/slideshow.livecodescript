script "slideshow.lc"
command index
   put transport_DroppedUrl ($_POST_RAW) into droppedURL
   put fedwiki_ConstructUrlArray (droppedURL) into urlArray
   
   put fedwiki_ConstructSimplePageArray ("Test Page") into newPageArray
   
   put item 2 of the extents of urlArray into lastLineUpNum
   repeat with lineUpNum = 1 to lastLineUpNum
   put fedwiki_GetLineUpJson (urlArray, lineUpNum) into someJSON
   put json_ToArray (someJSON) into pageArray
   put pageArray ["story"][1] into itemArray
   
   fedwiki_PageArrayAddToEnd itemArray, newPageArray
end repeat
   fedwiki_CleanJournalArray newPageArray
   put json_FromArray (newPageArray) into someJSON
   transport_ReturnJSON someJSON
end index
