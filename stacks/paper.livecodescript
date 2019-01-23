script "paper.lc" with behavior "behavior_RigLocalOveride"
getprop dep_StackNames
   return "lib_Fedwiki,lib_Dropbox,model_Secret"
end dep_StackNames

on index
   -- https://paper.dropbox.com/doc/Writing-with-markdown--AUmjuiRGj1RLWCuvBHoOdxNFAg-Os7UBN3uhgSfPEdi0rqQf
   put fedwiki_GetDroppedUrl ($_POST_RAW) into droppedURL
   switch
      case matchText (droppedURL, "https://paper.dropbox.com/doc/(.+)--([^-]+)-(.+)", docTitleBit, probUserID, docID)
         -- import_paper
         put paper_FetchDoc (docID) into docMarkdown
         put fedwiki_ConstructMarkdownPage (docMarkdown) into pageArray
         fedwiki_ReturnPageArray pageArray
         break
      case droppedURL ends with ".json"
         paper_from_wiki
         break
      default
         fedwiki_ExitAndReturnError droppedURL, "Not an Dropbox Paper document!"
   end switch
end index

on paper_from_wiki
   put fedwiki_GetDroppedUrl ($_POST_RAW) into droppedURL
   --
   fedwiki_TestJsonUrl droppedURL, pageTitle, storyArray, journalArray
   if the result is false then
      fedwiki_ExitAndReturnError droppedURL, "Not an Fedwiki json url!"
   end if
   
   put fedwiki_ConstructPageMarkdown (pageTitle, storyArray) into pageMarkdown
   --
   paper_CreateDocument pageMarkdown
   put the result into resultJSON
   
   -- here we can create a database as api does not provide info
   put fedwiki_ConstructErrorJSON (resultJSON) into pageJSON
   fedwiki_ReturnJSON pageJSON
   
   return pageJSON
end paper_from_wiki


/* == Test ==
*/
command test_UpdateDoc
   put CR & "# Super Last Updated Title" into newMarkdown
   put CR & "The End" after newMarkdown
   --
   paper_UpdateDocument newMarkdown, "1lBbii77MFLTuMga6ceyU"
   put the result into someJSON
   display_JSON someJSON
end test_UpdateDoc

command test
   put "# Test" into pageMarkdown
   put "rhSg9X3q2gc" into videoID
   put CR & CR & "[https://youtu.be/" & videoID & "](https://youtu.be/" & videoID & ")" after pageMarkdown
   put CR & CR & "https://www.youtube.com/watch?v=rhSg9X3q2gc&" after pageMarkdown
   put CR & CR & "https://youtu.be/" & videoID after pageMarkdown
   -- put CR & CR & "Hello" after pageMarkdown
   
   paper_CreateDocument pageMarkdown
   put the result
   
   /* 
   put "Os7UBN3uhgSfPEdi0rqQf" into paperID
   put paper_FetchDocumentInfo ("Os7UBN3uhgSfPEdi0rqQf") into someJSON
   
   put dropbox_GetAuthToken() into dropBoxAuthToken
   dropboxListFolder dropBoxAuthToken, "", false, false
   put it into someJSON
   display_JSON someJSON
   
   put dropbox_ListFolders() into someJSON
   display_JSON someJSON
   
   put "id:1lBbii77MFLTuMga6ceyU" into somePath
   put "/Updated Title" into somePath
   put "/Prova.txt" into somePath
   
   put "/audio/agile publishing.mp3" into somePath
   put "id:DgnHbhcn138AAAAAAAAG4A" into somePath
   put "/updated title" into somePath
   --
   put dropbox_FetchMetadata (somePath) into someArray
   display_Array someArray
   
   put "id:Os7UBN3uhgSfPEdi0rqQf" into paperID
   put dropbox_FetchMetadata (paperID) into someArray
   put dropbox_GetFileInfo (paperID) into fileInfoArray
   display_Array fileInfoArray
   
   dropboxGetMetadata dropBoxAuthToken, "Os7UBN3uhgSfPEdi0rqQf"
   put it into someJSON
   put someJSON
   */
end test
