script "scrape.lc"
getprop dep_StackNames
   return "lib_Audioboom,lib_Citation,lib_Curly,lib_Fedwiki,lib_HTML,lib_ImageMagick,lib_Map,lib_PageArray,lib_REST,lib_Scrape,lib_Transport,lib_XHTML,model_PageArray"
end dep_StackNames

on index
   -- Respond to Ward's Fedwiki scrape-completion webhook
   
   put fedwiki_GetDroppedArray() into postArray
   put postArray ["date"] into lastUpdatedSeconds
   --
   -- atopia_TrashAndUpdateModified
   -- put the result into atopiaCatModel
   --
   put transport_ConstructUpdatePageArray (lastUpdatedSeconds, postArray) into pageArray
   transport_StorePageArray pageArray
   put the result into tResult
   --
   if item 1 of tResult is "error" then
      put pageArray_Construct ("Bad", tResult) into responseArray
   else
      put pageArray_Construct ("Good", tResult) into responseArray
   end if
   pageArray_AddMarkdown responseArray, "That is all for now. We will return more useful data here at a later date."
   fedwiki_ReturnPageArray responseArray
end index

on htmlPage
   transport_DropTest droppedURL, srcImageURL, qEnd, isFavicon
   put the result into imageAttributeArray
   --
   switch
      case isFavicon
         put pageArray_Construct ("Test","You dropped a fedwiki favicon") into pageArray
         fedwiki_ReturnPageArray pageArray
         break
      case srcImageURL begins with "https://www.google.com/search?q="
      case srcImageURL begins with "https://www.google.com/imgres?imgurl="
         put pageArray_ConstructGoogleImagePage (imageURL) into pageArray
         break
      case srcImageURL is not empty
         put pageArray_ConstructImageEditPage (srcImageURL, imageAttributeArray, true) into pageArray
         fedwiki_ReturnPageArray pageArray
         break
      case qEnd is among the items of "ogg,mp3,m4A,wav"
         put pageArray_Construct ("Dropped Audio", "Drag audio file to anothe page...") into pageArray
         put fedwiki_ConstructImageCaption ("Dropped audio", droppedURL) into audioCaption
         pageArray_AddAudio pageArray, droppedURL, audioCaption
         fedwiki_ReturnPageArray pageArray
         break
      case qEnd is among the items of "mp4,webm"
      case droppedURL begins with "https://www.youtube.com/"
      case droppedURL begins with "https://vimeo.com/"
      case droppedURL begins with "https://www.ted.com/talks/"
         fedwiki_ForwardAndReturn "https://rest.livecode.world/youtube"
         break
      case matchText (droppedURL, "https://www.pinterest.com/pin/(.+)/|https://www.pinterest.co.uk/pin/(.+)/", photoID)
         fedwiki_ForwardAndReturn "https://rest.livecode.world/pinterest"
         break
      case matchText (droppedURL, "https://www.flickr.com/photos/(.+)/(.+)/in/.+", userID, photoID)
         fedwiki_ForwardAndReturn "https://rest.livecode.world/flickr"
         break
      case qEnd is among the items of "jpg,jpeg,png,gif,webp,svg"
         fedwiki_ForwardAndReturn "https://rest.livecode.world/photo"
         break
      case droppedURL begins with "https://www.google.com/imgres?imgurl="
      case droppedURL begins with "https://www.google.co.uk/imgres?imgurl="
         fedwiki_ForwardAndReturn "https://rest.livecode.world/google"
         break
      default
         put scrape_ConstructFedwikiPageArray (droppedURL) into pageArray
         fedwiki_ReturnPageArray pageArray
   end switch
end htmlPage
