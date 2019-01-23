script "asana.lc" with behavior "behavior_RigLocalOveride"
getprop dep_StackNames
   return "lib_Fedwiki,lib_Asana,model_Secret,lib_REST"
end dep_StackNames

on index
   put fedwiki_GetDroppedUrl ($_POST_RAW) into droppedURL
   
   -- https://app.asana.com/0/844764154321997/914611904511854
   if matchText (droppedURL, "https://app.asana.com/0/(.+)/(.+)", projectID, taskID) is false then
      put fedwiki_IsFaviconDrop() into isFavicon
      if isFavicon is true then
         asana_CreateTaskFromWiki droppedURL
         put the result into fedwikiPageArray
         --
         fedwiki_ReturnPageArray fedwikiPageArray
         exit to top
      else
         fedwiki_ExitAndReturnError droppedURL, "Not an Asana task"
      end if
   end if
   
   switch
      case taskID = "list"
         put asana_FetchProjectPageArray (projectID) into fedwikiPageArray
         fedwiki_ReturnPageArray fedwikiPageArray
         break
      case taskID is a number
         put asana_FetchTaskPageArray (taskID) into fedwikiPageArray
         fedwiki_ReturnPageArray fedwikiPageArray
         break
      default
         fedwiki_ExitAndReturnError droppedURL, "Not an Asana project task"
   end switch
end index
