script "audioboom.lc"
getprop dep_StackNames
   return "lib_Array,lib_Audioboom,lib_Fedwiki,lib_MediaWiki,lib_PageArray,lib_REST,model_PageArray"
end dep_StackNames

on index
   put transport_DroppedUrl ($_POST_RAW) into droppedURL
   switch
      case droppedURL is empty
         put "Error, expecting an audioboo clip url and it is empty" into errorText
         put pageArray_Construct ("Error", errorText) into pageArray
         break
      case droppedURL is a number
         -- let's assume it is an audioboom-clip-ID
         put audioboom_ClipJsonFromUrl (droppedURL) into someJSON
         put json_ToArray (someJSON) into pageArray
         break
      default
         put audioboom_ClipJsonFromUrl (droppedURL) into someJSON
         if someJSON is empty then
            put "Error, this was not an audioboo clip url" into errorText
            put fedwiki_ConstructNewPageArray ("Error", errorText) into pageArray
         else
            put json_ToArray (someJSON) into pageArray
         end if
   end switch
   --
   transport_ReturnPageArray pageArray
end index
