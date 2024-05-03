script "flickr.lc" with behavior "behavior_RigLocalOveride"
getprop dep_StackNames
    return "lib_Flickr,lib_FlickrAuth,lib_Fedwiki,model_Library"
end dep_StackNames

on index
   /*
   The model is creating dependencies for model_Library and lib_LCW which are not needed on the server?
   pinterest is mixed in here an should be seperated out
   */
   put transport_DroppedUrl ($_POST_RAW) into droppedURL
   
   set the itemdelimiter to slash
   get item 1 to 4 of droppedURL
   switch
      case it = "https://www.flickr.com/photos"
         -- https://www.flickr.com/photos/152869685@N06/35893520742/in/pool-3569415@N23
         -- https://www.flickr.com/photos/152869685@N06/35253400043/in/album-72157683812549094/
         
         flickr_FetchAndDeconstructFromDroppedUrl droppedURL, photoTitle, photoDescription, mediumURL, photoTags
         put the result into photoArray
         put photoArray ["location"] into locationArray
         put flickr_ConstructPhotoMapPageArray (photoTitle, photoDescription, mediumURL, droppedURL, locationArray, photoTags) into pageJSON
         break
      default
         set the itemdelimiter to "."
         if item -1 of droppedURL is among the items of "jpg.jpeg.png.gif" then
            local pageArray
            _AddImageToPageArray pageArray, droppedURL
            put json_FromArray (pageArray) into pageJSON
         else
            put transport_ConstructErrorJSON ("URL not recognised") into pageJSON
         end if
   end switch
   
   transport_ReturnJSON pageJSON
end index

on flickr droppedURL
   if droppedURL is empty then
      put transport_DroppedUrl() into droppedURL
   end if
   
   if matchText (droppedURL, "https://www.flickr.com/photos/(.+)/(.+)/in/.+", userID, photoID) then
      flickr_FetchAndDeconstructFromDroppedUrl droppedURL, photoTitle, photoDescription, mediumURL, photoTags
      put the result into photoArray
      put photoArray ["location"] into locationArray
      put flickr_ConstructPhotoMapPageArray (photoTitle, photoDescription, mediumURL, droppedURL, locationArray, photoTags) into pageJSON
      transport_ReturnJSON pageJSON
   else
      transport_ExitAndReturnError "Dropped url is nor recognised.", "Error"
   end if
end flickr

command _AddImageToPageArray @pageArray, imageURL
   put "Dropped Image" into pageTitle
   put "This is a simple image dropped on to a wiki." into someText
   put fedwiki_ConstructNewPageArray (pageTitle, someText) into pageArray
   
   put "This is an image" into imageCaption
   put html_ExtractTLD (imageURL, true) into tldBit
   put "-" && tldBit into linkInfo
   
   put imageURL into descriptionURL
   put fedwiki_ConstructImageHtml (imageURL, imageCaption, descriptionURL, linkInfo) into imageHTML
   fedwiki_AddHtmlToPageArray pageArray, imageHTML
end _AddImageToPageArray

function html_ExtractTLD someURL, pLastTwo
   set the itemdelimiter to slash
   put item 3 of someURL into someTLD
   if pLastTwo is not true then return someTLD

   set the itemdelimiter to "."
   put item -2 to -1 of someTLD into tldBit
   return tldBit
end html_ExtractTLD

on flickr droppedURL
   if droppedURL is empty then
      put transport_DroppedUrl ($_POST_RAW) into droppedURL
   end if
   
   if matchText (droppedURL, "https://www.flickr.com/photos/(.+)/(.+)/in/.+", userID, photoID) then
      flickr_FetchAndDeconstructFromDroppedUrl droppedURL, photoTitle, photoDescription, mediumURL, photoTags
      put the result into photoArray
      put photoArray ["location"] into locationArray
      put flickr_ConstructPhotoMapPageArray (photoTitle, photoDescription, mediumURL, droppedURL, locationArray, photoTags) into pageJSON
      transport_ReturnJSON pageJSON
   else
      transport_ExitAndReturnError "Dropped url is nor recognised.", "Error"
   end if
end flickr
