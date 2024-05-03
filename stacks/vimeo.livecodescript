script "vimeo.lc"
getprop dep_StackNames
   return "lib_Fedwiki,lib_PageArray,lib_Vimeo,model_PageArray"
end dep_StackNames

on index
   put transport_DroppedUrl ($_POST_RAW) into droppedURL
   switch
      case matchText (droppedURL, "https\://vimeo\.com/(.+)", vimeoID)
         put vimeo_ConstructPageArray (vimeoID) into pageArray
         break
      default
         put "This is not a Vimeo video. URL =" && droppedURL into errorText
         put pageArray_Construct ("Error", errorText) into pageArray
   end switch
   --
   transport_ReturnPageArray pageArray
end index

on high
   put transport_DroppedUrl ($_POST_RAW) into droppedURL
   switch
      case matchText (droppedURL, "https\://vimeo\.com/(.+)", vimeoID)
         put vimeo_ConstructPageArray (vimeoID, 6) into pageArray
         break
      default
         put "This is not a Vimeo video. URL =" && droppedURL into errorText
         put pageArray_Construct ("Error", errorText) into pageArray
   end switch
   --
   transport_ReturnPageArray pageArray
end high

on thumbs
   put transport_DroppedUrl ($_POST_RAW) into droppedURL
   --
   switch
      case matchText (droppedURL, "https\://vimeo\.com/(.+)", vimeoID)
         put pageArray_Construct ("Vimeo Thumbnails", "This video has the following thumbnails:") into pageArray
         --
         put vimeo_ListThumbnails (vimeoID) into thumbNailUrls
         if thumbNailUrls is not empty then
            pageArray_AddMarkDown pageArray, "# Thumbnails"
            repeat for each line thumbNailUrl in thumbNailUrls
               pageArray_AddHtmlImage pageArray, thumbNailUrl
            end repeat
         end if
         break
      default
         put "This is not a Vimeo video. URL =" && droppedURL into errorText
         put pageArray_Construct ("Error", errorText) into pageArray
   end switch
   --
   transport_ReturnPageArray pageArray
end thumbs

on test
   /*   put rigFetchConfigItem ("VimeoApiKey") into vimeoApiKey
   put "Vimeo URL =" && droppedURL into someMarkdown
   put CR & "# VimeoApiKey" & CR after someMarkdown
   put vimeoApiKey & CR after someMarkdown
   */
   
   put vimeo_FetchVerifyAuthJson ("oauth/verify", true) into vimeoData
   -- put vimeo_FetchVideoJSON (vimeoID) into vimeoData
   --
   if vimeoData is not an array then
      put pageArray_Construct ("Error", vimeoData) into pageArray
   else
      put vimeoData ["name"] into vimeoTitle
      put pageArray_Construct (vimeoTitle, someMarkdown) into pageArray
   end if
end test
