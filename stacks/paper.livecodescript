﻿script "paper.lc" with behavior "behavior_RigLocalOveride"
getprop dep_StackNames
   return "lib_Fedwiki,lib_PageArray,lib_RevIgniter,lib_DropBox,model_Secret"
end dep_StackNames

on index
   -- https://paper.dropbox.com/doc/Writing-with-markdown--AUmjuiRGj1RLWCuvBHoOdxNFAg-Os7UBN3uhgSfPEdi0rqQf
   put transport_DroppedUrl() into droppedURL
   switch
      case matchText (droppedURL, "https://paper.dropbox.com/doc/(.+)--([^-]+)-(.+)", docTitleBit, probUserID, docID)
         -- import_paper
         put paper_FetchDoc (docID) into docMarkdown
         put fedwiki_ConstructMarkdownPage (docMarkdown) into pageArray
         transport_ReturnPageArray pageArray
         break
      case droppedURL ends with ".json"
         paper_from_wiki
         break
      default
         transport_ExitAndReturnError droppedURL, "Not an Dropbox Paper document!"
   end switch
end index

on paper_update docID, revisionID
   if the environment = "server" then
      put rigFetchSegment(3, "") into docID
      put rigFetchSegment(4, "") into revisionID
   else
      put "DfTlWvGHJCz8abte3fvPb" into docID
      put 7 into revisionID
   end if
   put transport_DroppedUrl ($_POST_RAW) into droppedURL
   
   put "# Hello World/n" & droppedURL into newMarkdown
   --
   paper_UpdateDocument newMarkdown, docID, revisionID
   put the result into resultJSON
   
   put revisionID && resultJSON into someText
   transport_ExitAndReturnError someText, "Here is the Doc ID"
end paper_update

on paper_from_wiki
   rigLoadHelper "file"
   put "./assets/json/paper.json" into jsonAssetPath
   --
   put transport_DroppedUrl ($_POST_RAW) into droppedURL
   --
   fedwiki_TestJsonUrl droppedURL, pageTitle, storyArray, journalArray
   if the result is false then
      transport_ExitAndReturnError droppedURL, "Not an Fedwiki json url!"
   end if
   
   put fedwiki_ConstructPageMarkdown (pageTitle, storyArray) into pageMarkdown
   --
   paper_CreateDocument pageMarkdown
   put the result into resultJSON
   --
   rig_SetJson jsonAssetPath, resultJSON
   put the result into storeResult
   put rig_GetJson (jsonAssetPath) into resultJSON
   put rigGetFileInfo (jsonAssetPath, "serverPath") into serverPath
   
   
   /*
   {"doc_id": "S0kqkDjSQjPHZea06WqHn", "revision": 2, "title": "Paper Transport"}
   */
   put json_ToArray (resultJSON) into resultArray
   put resultArray ["doc_id"] into docID
   put resultArray ["revision"] into revisionNum
   put resultArray ["title"] into pageTitle
   --
   put paper_ConstructDocUrl (docID) into docURL
   
   put serverPath into curlyArray ["Page Title"]
   put docURL into curlyArray ["Dropbox Paper Document URL"]
   put docID into curlyArray ["Paper DocID"]
   
   -- here we can create a database as api does not provide info
   -- http://transport.fedwiki.org/view/welcome-visitors/view/paper-transport/view/paper-dialogue-template
   -- put fedwiki_FetchPageTemplate ("transport.fedwiki.org", "paper-dialogue-template", "Dropbox Paper Document URL", docURL) into pageArray
   put fedwiki_FetchPageTemplate ("transport.fedwiki.org", "paper-dialogue-template", curlyArray) into pageArray
   --
   put "Update" && pageTitle into pageArray ["title"]
   --
   transport_ReturnPageArray pageArray
   
   /*
   put transport_ConstructErrorJSON (resultJSON) into pageJSON
   transport_ReturnJSON pageJSON
   return pageJSON
   */
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

function fedwiki_ConstructPageMarkdown pageTitle, storyArray
   -- put fedwiki_ConstructMarkdownPage (someMarkdown, pPageTitle)
   put "#" && pageTitle & CR into pageMarkdown
   --
   repeat with itemNum = 1 to item 2 of the extents of storyArray
      put storyArray [itemNum]["type"] into itemType
      put storyArray [itemNum]["text"] into itemText
      put word 1 to -1 of itemText into itemText
      
      -- let's replace external wiki links with normal html links
      fedwiki_ReplaceExternalLinks itemText
      --
      switch itemType
         case "markdown"
            if word 1 of itemText = "#" then
               put "##" into word 1 of itemText
               put itemText & CR after pageMarkdown
            else
               put itemText & CR & CR after pageMarkdown
            end if
            break
         case "video"
            _AddVideo pageMarkdown, itemText
            break
         case "html" -- could convert?
         case "text"
         default
            put itemText & CR & CR after pageMarkdown
      end switch
   end repeat
   return pageMarkdown
end fedwiki_ConstructPageMarkdown

private command _AddVideo @pageMarkdown, itemText
   put word 1 of itemText into sWord
   put word 2 of itemText into videoID
   switch sWord
      case "YOUTUBE"
         put "[https://youtu.be/" & videoID & "](https://youtu.be/" & videoID & ")" & CR & CR after pageMarkdown
         -- put youtube_ConstructWatchUrl (videoID) & CR & CR after pageMarkdown
         break
      case "Vimeo"
         put vimeo_ConstructWatchUrl (videoID) & CR & CR after pageMarkdown
         break
      default
         put itemText & CR & CR after pageMarkdown
   end switch
end _AddVideo
