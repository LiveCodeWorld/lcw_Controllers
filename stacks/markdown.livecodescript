script "markdown.lc" with behavior "behavior_RigLocalOveride"
getprop dep_StackNames
    return "lib_Fedwiki"
end dep_StackNames

on index
   put transport_DroppedUrl ($_POST_RAW) into droppedURLUrl
   put fedwiki_FetchPageArray (droppedURLUrl) into droppedPageArray
   --
   put fedwiki_PageArrayToMarkdown (droppedPageArray) into someMarkDown
   --
   put "Markdown Export" into pageTitle
   put "Copy and paste the markdown from the item below:" into firstParagraph
   put fedwiki_ConstructNewPageArray (pageTitle, firstParagraph) into pageArray
   fedwiki_AddMarkdownToPageArray pageArray, someMarkdown
   --
   transport_ReturnPageArray pageArray
end index

function fedwiki_PageArrayToMarkdown pageArray
   put pageArray ["story"] into storyArray
   put item 2 of the extents of storyArray into maxNum
   repeat with storyNum = 1 to maxNum
      put storyArray [storyNum] into itemArray
      put itemArray ["type"] into itemType
      put itemArray ["text"] into someText
      --
      switch itemType
         case "paragraph"
            get word 1 to -1 of someText
            put it  & CR&CR after someMarkdown
            break
         case "markdown"
            get word 1 to -1 of someText
            put it  & CR&CR after someMarkdown
            break
         default
            get word 1 to -1 of someText
            put it  & CR&CR after someMarkdown
      end switch
   end repeat
   delete char -2 to -1 of someMarkdown
   return someMarkdown
end fedwiki_PageArrayToMarkdown
