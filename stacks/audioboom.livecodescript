script "audioboom.lc" with behavior "behavior_RigLocalOveride"
getprop dep_StackNames
   return "lib_Audioboom,lib_Fedwiki,lib_REST"
end dep_StackNames

command index
   put fedwiki_GetDroppedUrl ($_POST_RAW) into droppedURL  
   switch
      case droppedURL is empty
         put "Error, expecting an audioboo clip url and it is empty" into errorText
         put fedwiki_ConstructErrorJSON (errorText) into someJSON
         break
      case droppedURL is a number
         -- let's assume it is an audioboom-clip-ID
         put audioboom_ClipJsonFromUrl (droppedURL) into someJSON
         break
      default
         put audioboom_ClipJsonFromUrl (droppedURL) into someJSON
         if someJSON is empty then
            put "Error, this was not an audioboo clip url" into errorText
            put fedwiki_ConstructNewPageArray ("Error", errorText) into someArray
            put json_FromArray (someArray) into someJSON
         end if
   end switch
   fedwiki_ReturnJSON someJSON
end index
