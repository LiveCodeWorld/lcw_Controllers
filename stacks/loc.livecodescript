script "loc.lc"
getprop dep_StackNames
   return "lib_Fedwiki,lib_PageArray,model_PageArray"
end dep_StackNames

on index
   put fedwiki_GetDroppedUrl() into droppedURL
   --
   put "https://www.loc.gov/pictures/collection/.+/item/(.+)/" into someReg
   if matchText (droppedURL, someReg, itemID) is true then
      put merge ("https://www.loc.gov/item/[[itemID]]/?fo=json") into jsonUrl
      put url jsonUrl into someJSON
      put json_ToArray (someJSON) into locArray
      --
      put locArray ["item"]["location"] into locationArray
      put locArray ["item"]["locations"] into locationsArray
      --
      put locArray ["item"]["place"][1] into placeArray
      put placeArray ["link"] into placeImagesURL
      put placeArray ["latitude"] into latURL
      put placeArray ["longitude"] into longURL
      put placeArray ["title"] into placeTitle
      --
      put locArray ["item"]["title"] into imageTitle
      put locArray ["item"]["description"] into imageDescription
      --
      put locArray ["item"]["image_url"][1] into largeImageURL
      put locArray ["item"]["image_url"][2] into smallImageURL
      --
      put pageArray_Construct ("Library of Congress Image", imageTitle) into pageArray
      --
      pageArray_AddMarkdown pageArray, placeImagesURL
      pageArray_AddImage pageArray, smallImageURL, placeTitle, placeImagesURL
      --
   else
      put "We did not recognise the dropped url" && droppedURL into someError
      put pageArray_Construct ("Error", someError) into pageArray
   end if
   --
   fedwiki_ReturnPageArray pageArray
end index
