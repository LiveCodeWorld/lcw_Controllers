script "map.lc"
getprop dep_StackNames
    return "lib_Exif,lib_Fedwiki,lib_Map,lib_MediaWiki,lib_PageArray,lib_WikiSandbox,model_PageArray"
end dep_StackNames

on index
   put fedwiki_GetDroppedUrl() into droppedURL
   -- put "https://en.wikipedia.org/wiki/Stonehenge" into droppedURL
   -- https://www.google.com/maps/place/Funkhaus+Berlin+Nalepastrasse/@52.479543,13.500279,11z/data=!4m5!3m4!1s0x0:0x163f2116c5300be2!8m2!3d52.4795432!4d13.5002786?hl=en-GB
   -- put "https://www.openstreetmap.org/?mlat=51.178844&mlon=-1.826189&zoom=15#map=15/51.1788/-1.8262" into droppedURL
   --
   switch
      case matchText (droppedURL, "https://(.+).wikipedia.org/wiki/(.+)", wikiLanguage, wikiSlug)
         put openStreetMap_FetchWikipediaMapPageArray (wikiSlug) into pageArray
         fedwiki_ReturnPageArray pageArray
         break
      case matchText (droppedURL, "^https:\/\/(..)\.wikipedia.org\/w\/index.php\?title=(.+)&action=edit&section=(.+)$", someLang, pageTitle, sectionNum)
         put openStreetMap_FetchWikipediaMapPageArray (pageTitle) into pageArray
         fedwiki_ReturnPageArray pageArray
         break
      case matchtext (droppedURL, "^https://tools.wmflabs.org/geohack/geohack.php\?pagename=(.+)&params=(.+)", pageName, geoInfo)
         wmflabs_ReturnPageArray pageName, geoInfo
         break
      case droppedURL begins with "http://www.openstreetmap.org/"
      case droppedURL begins with "https://www.openstreetmap.org/"
         openStreetMap_ReturnPageArray droppedURL
         break
      case droppedURL begins with "https://www.google.co.uk/maps/place/"
      case droppedURL begins with "https://www.google.com/maps/place/"
         googleMaps_ReturnPageArray droppedURL
         break
      default
         geoImage_ReturnPageArray
   end switch
end index
