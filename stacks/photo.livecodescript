script "photo.lc" with behavior "behavior_RigLocalOveride"
getprop dep_StackNames
   return "lib_Curly,lib_Fedwiki,lib_HTML,lib_Image,lib_ImageMagick,lib_Map,lib_PageArray,model_PageArray"
end dep_StackNames

on index
   transport_DropTest imageURL, srcImageURL, qEnd, isFavicon
   put the result into imageAttributeArray
   --
   switch 
      case imageURL begins with "https://www.google.com/search?q="
      case imageURL begins with "https://www.google.com/imgres?imgurl="
         put wikiPage_GoogleImage (imageURL) into pageArray
         break
      case srcImageURL is not empty
         put wikiPage_ImageEditor (srcImageURL, imageAttributeArray, true) into pageArray
         break
      default
         -- put urldecode (imageURL) into imageURL
         put wikiPage_ImageEditor (imageURL, empty, false) into pageArray
   end switch
   --
   transport_ReturnPageArray pageArray
end index

on edit_Image
   put transport_GetRawJSON() into dropJSON
   put json_ToArray (dropJSON) into paramArray
   --
   put paramArray ["pageSlug"] into pageSlug
   put paramArray ["pageTitle"] into pageTitle
   put paramArray ["wikiDomain"] into wikiDomain
   --
   put pageArray_Fetch (wikiDomain, pageSlug) into pageArray
   put pageArray_FindItemType ("html", pageArray, 0) into itemNum
   put pageArray ["story"][itemNum] into itemArray
   put itemArray ["text"] into imageHtml
   
   if imageHtml contains "<img data-imagestyle=" then
      /*
      <div style='padding: 12px; background:#eee; width:96%; align=centered;'>
      <a href='https://upload.wikimedia.org/wikipedia/commons/e/ea/Vannevar_Bush_portrait.jpg' target='_blank'>
      <img data-imagestyle='fullwiki'; style='display:block; margin:auto; width:100%;' src='https://upload.wikimedia.org/wikipedia/commons/thumb/e/ea/Vannevar_Bush_portrait.jpg/320px-Vannevar_Bush_portrait.jpg'>
      </a>
      <p class=caption>
      */      
      get matchText (imageHtml, "<img .* src='(.+)'>", imageURL)
      put xml_ToArray (imageHtml) into imageArray
      put word 1 to -1 of imageArray ["div"]["p"] into imageCaption
      put imageArray ["div"]["a"]["@attributes"]["href"] into imageLink
      --
      put itemArray ["id"] into sID
      --
      put itemArray_Construct ("image", sID, imageCaption) into imageArray
      put imageURL into imageArray ["url"]
      put "wide" into imageArray ["size"]
      put imageLink into imageArray ["source"]
      --
      /*
      put url imageURL into sImage
      put md5_Hash (sImage) & "." & fExt into shortImageFile
      put wikiFile_ConstructImageAsset (shortImageFile, wikiDomain) into imageFile
      hardlink_Create fromFile, toFile
      
      put sWidth into imageArray ["width"]
      put sHeight into imageArray ["height"]
      */
      
      put pageArray_Construct ("Converted Image", "here is an image...") into pageArray
      itemArray_Add imageArray, pageArray
   end if
   -- put wikiPage_ImageEditor (srcImageURL, imageAttributeArray, true) into pageArray
   --
   transport_ReturnPageArray pageArray
end edit_Image

on imageMetadata
   put transport_GetDroppedArray() into postArray
   put postArray ["imageURL"] into imageURL
   -- put "https://www.zsl.org/sites/default/files/styles/wysiwyg/public/image/2014-01/Butterfly%2025.5.06%20115.jpg" into imageURL
   --
   put pageArray_ConstructMapAndImage (imageURL, "Image Metadata") into pageArray
   --
   transport_ReturnPageArray pageArray
end imageMetadata

on charcoal
   put transport_GetDroppedArray() into postArray
   put postArray ["imageURL"] into imageURL
   put postArray ["imageCaption"] into imageCaption
   put postArray ["imageWidth"] into imageWidth
   --
   put imageMagick_FetchImageType (imageURL) into imageType
   put imageMagick_GrayScale (imageURL, imageType) into someImage
   put pageArray_ConstructEmbeddedImage (someImage, imageType, "Grayscale Image", imageWidth) into pageArray
   --
   transport_ReturnPageArray pageArray
end charcoal

on grayscale
   put transport_GetDroppedArray() into postArray
   put postArray ["imageURL"] into imageURL
   put postArray ["imageCaption"] into imageCaption
   put postArray ["imageWidth"] into imageWidth
   --
   put imageMagick_FetchImageType (imageURL) into imageType
   put imageMagick_Charcoal (imageURL, imageType, 3) into someImage
   put pageArray_ConstructEmbeddedImage (someImage, imageType, "Charcoal Image", imageWidth) into pageArray
   --
   transport_ReturnPageArray pageArray
end grayscale

on embedImage
   put transport_GetDroppedArray() into postArray
   put postArray ["imageURL"] into imageURL
   put postArray ["imageCaption"] into imageCaption
   put postArray ["imageWidth"] into imageWidth
   --   
   put imageMagick_FetchIdentity (imageURL) into identityInfo
   put imageMagick_GetImageType (identityInfo) into imageType
   --
   -- put url imageURL into someImage
   put imageMagick_Shrink (imageURL, imageWidth, imageWidth) into someImage
   put pageArray_ConstructEmbeddedImage (someImage, imageType, imageCaption, imageWidth) into pageArray
   --
   pageArray_AddPagefold pageArray, "Metadata"
   pageArray_AddCode pageArray, identityInfo
   --
   transport_ReturnPageArray pageArray
end embedImage

function pageArray_ConstructEmbeddedImage someImage, imageType, imageCaption, imageWidth
   put "Embedded Image" into pageTitle
   --
   put pageTitle into pageArray ["title"]
   put journalArray_Construct (pageTitle) into pageArray ["journal"] 
   --
   pageArray_AddEmbeddedImage pageArray, someImage, imageCaption, imageType
   --
   put "This is a [[base64 encoded image]] that has been emedded into the the [[wiki-page]]." into someMarkdown
   put CR&CR & "This [[ghost-page]] has not been saved yet." after someMarkdown
   put "You can drag the image to another page (or fork this page) to save a permanent snapshot of this image to wiki." after someMarkdown
   pageArray_AddMarkdown pageArray, someMarkdown
   --
   return pageArray
end pageArray_ConstructEmbeddedImage
