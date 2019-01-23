script "pinterest.lc"
getprop dep_StackNames
    return "lib_Pinterest,lib_Fedwiki,model_Secret"
end dep_StackNames

on index
   local pageArray
   put fedwiki_GetDroppedUrl ($_POST_RAW) into droppedURL
   
   switch
      case matchText (droppedURL, "https://www.pinterest.com/pin/(.+)/|https://www.pinterest.co.uk/pin/(.+)/", photoID)
      case matchText (droppedURL, "https://www.pinterest.co.uk/pin/(.+)/|https://www.pinterest.co.uk/pin/(.+)/", photoID)
         -- https://www.pinterest.com/pin/134545107601633296/
         put pinterest_FetchPinPageJson (photoID) into pageJSON
         fedwiki_ReturnJSON pageJSON
         break
      default
         -- webpage droppedURL
         fedwiki_ExitAndReturnError "Dropped url is nor recognised.", "Error"
         break
   end switch
end index
