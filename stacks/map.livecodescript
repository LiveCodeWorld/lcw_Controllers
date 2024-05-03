script "map.lc"
getprop dep_StackNames
    return "lib_Exif,lib_Fedwiki,lib_Map,lib_MediaWiki,lib_PageArray,lib_WikiSandbox,model_PageArray"
end dep_StackNames

on index
   put transport_DroppedUrl() into droppedURL
   -- put "https://en.wikipedia.org/wiki/Stonehenge" into droppedURL
   -- https://www.google.com/maps/place/Funkhaus+Berlin+Nalepastrasse/@52.479543,13.500279,11z/data=!4m5!3m4!1s0x0:0x163f2116c5300be2!8m2!3d52.4795432!4d13.5002786?hl=en-GB
   -- put "https://www.openstreetmap.org/?mlat=51.178844&mlon=-1.826189&zoom=15#map=15/51.1788/-1.8262" into droppedURL
   --
   switch
      case matchtext (droppedURL, "^https://geohack.toolforge.org/geohack.php\?pagename=(.+)&params=(.+)", pageName, geoInfo)
         -- https://geohack.toolforge.org/geohack.php?pagename=Tinker%27s_Bubble&params=50_56_N_2_44_W_
         wmflabs_ReturnPageArray pageName, geoInfo
         break
      case matchText (droppedURL, "https://(.+).wikipedia.org/wiki/(.+)", wikiLanguage, wikiSlug)
         put openStreetMap_FetchWikipediaMapPageArray (wikiSlug) into pageArray
         transport_ReturnPageArray pageArray
         break
      case matchText (droppedURL, "^https:\/\/(..)\.wikipedia.org\/w\/index.php\?title=(.+)&action=edit&section=(.+)$", someLang, pageTitle, sectionNum)
         put openStreetMap_FetchWikipediaMapPageArray (pageTitle) into pageArray
         transport_ReturnPageArray pageArray
         break
      case droppedURL begins with "http://www.openstreetmap.org/"
      case droppedURL begins with "https://www.openstreetmap.org/"
         openStreetMap_ReturnPageArray droppedURL
         break
      case droppedURL begins with "https://www.google.co.uk/maps/place/"
      case droppedURL begins with "https://www.google.com/maps/place/"
         googleMaps_ReturnPageArray droppedURL
         break
      case item 2 of droppedURL = "googleusercontent"
         put pageArray_ConstructMapAndImage (droppedURL) into pageArray
         transport_ReturnPageArray pageArray
         break
      case item -1 of droppedURL is among the items of "jpg.jpeg.png.giff"
         put pageArray_ConstructMapAndImage (droppedURL) into pageArray
         transport_ReturnPageArray pageArray
         break
      default
         transport_ExitAndReturnError "Nothing dropped", "Error"
   end switch
end index
