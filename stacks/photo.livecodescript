script "photo.lc" with behavior "behavior_RigLocalOveride"
getprop dep_StackNames
    return "lib_Fedwiki,lib_PageArray"
end dep_StackNames

on index
   put fedwiki_GetDroppedUrl() into droppedURL
   --
   put droppedURL into imageURL
   put imageURL into captionLinkURL
   --
   put "Dropped Image" into pageTitle
   put "This is a simple image dropped on to a wiki." into pageText
   put empty into imageCaption
   --
   put fedwiki_ConstructNewPageArray (pageTitle, pageText) into pageArray
   fedwiki_AddImageToPageArray pageArray, imageURL, imageCaption, captionLinkURL
   --
   fedwiki_ReturnPageArray pageArray
end index
