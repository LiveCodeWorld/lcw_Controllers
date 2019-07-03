script "map.lc"
getprop dep_StackNames
   return "lib_Exif,lib_Fedwiki,lib_PageArray,lib_RevIgniter"
end dep_StackNames

on index
   put fedwiki_GetDroppedUrl ($_POST_RAW) into droppedURL
   --
   switch
      case matchtext (droppedURL, "^https://tools.wmflabs.org/geohack/geohack.php\?pagename=(.+)&params=(.+)", pageName, geoInfo)
         -- put "https://tools.wmflabs.org/geohack/geohack.php?pagename=Harringay&params=51.5819_N_-0.0994_E_region:GB_type:city(13272)" into droppedURL
         -- put "https://tools.wmflabs.org/geohack/geohack.php?pagename=Bilbao&params=43_15_25_N_2_55_25_W_region:ES_type:city" into droppedURL
         --
         put urldecode (pageName) into pageName
         replace "_" with space in pageName
         put "Map of" && pageName into pageTitle
         put pageName into pinTitle
         --         
         geo_ExtractLatLong geoInfo, mLat, mLon, regionInfo
         --
         if mLat is not a number or mLat is not a number then
            fedwiki_ExitAndReturnError ("Problem parsing map data" && geoInfo,mLat,mLon), "Error"
            exit to top
         end if
         put 15 into mZoom -- should work out from regionInfo
         --
         put "http://www.openstreetmap.org/#map=" & mZoom & "/" & mLat & "/" & mLon into openstreetmapURL
         put "This is a map of [[" & pageName & "]]" into mapText
         put mapText && "- [" & openstreetmapURL && "openstreetmap]" into mapDescription
         --
         put fedwiki_OpenStreetMapPageArray (pageTitle, mLat, mLon, mZoom, mapDescription, pinTitle) into pageArray
         --
         put json_FromArray (pageArray) into pageJSON
         fedwiki_ReturnJSON pageJSON
         break
      case droppedURL begins with "http://www.openstreetmap.org/"
      case droppedURL begins with "https://www.openstreetmap.org/"
         -- https://www.openstreetmap.org/?mlat=48.39&mlon=-4.49&zoom=12#map=12/48.3900/-4.4900
         --
         set the itemdelimiter to "#"
         put item 1 of droppedURL into possiblyTitle
         put item 2 of droppedURL into afterHashBit
         if possiblyTitle contains "search?query=" then
            set the itemdelimiter to "="
            get item -1 of possiblyTitle
            put urldecode (it) into pageTitle
            put "OpenStreetMap of" && pageTitle into mapDescription
            put pageTitle into pinTitle
         else
            put "Somewhere" into pageTitle
            put "OpenStreetMap of somewhere" into mapDescription
            put "Some place" into pinTitle
         end if
         --
         set the itemdelimiter to "="
         get item -1 of afterHashBit
         set the itemdelimiter to slash
         put item 1 of it into mZoom
         put item 2 of it into mLat
         put item 3 of it into mLon
         --
         put "http://www.openstreetmap.org/#map=" & mZoom & "/" & mLat & "/" & mLon into openstreetmapURL
         put " - [" & openstreetmapURL && "openstreetmap]" after mapDescription
         --
         put fedwiki_OpenStreetMapPageArray (pageTitle, mLat, mLon, mZoom, mapDescription, pinTitle) into pageArray
         --
         put json_FromArray (pageArray) into pageJSON
         fedwiki_ReturnJSON pageJSON
         break
      case droppedURL begins with "https://www.google.co.uk/maps/place/"
      case droppedURL begins with "https://www.google.com/maps/place/"
         -- should use a regular expression to catch all international maps
         -- https://www.google.com/maps/place/Funkhaus+Berlin+Nalepastrasse/@52.479543,13.500279,11z/data=!4m5!3m4!1s0x0:0x163f2116c5300be2!8m2!3d52.4795432!4d13.5002786?hl=en-GB
         set the itemdelimiter to slash
         put urldecode (item 6 of droppedURL) into placeName
         --
         get item 7 of droppedURL
         -- @52.479543,13.500279,11z
         delete char 1 of it
         set the itemdelimiter to comma
         put item 1 of it into mlat
         put item 2 of it into mlon
         put item 3 of it into mZoom
         
         -- hack
         delete char -1 of mZoom
         put "Google Map of" && placeName into mapDescription
         put placeName into pageTitle
         --
         put pageTitle && "- [" & droppedURL && "google]" into mapDescription 
         
         put pageTitle into pinTitle
         put geo_ConstructHgeo (mlon, mlat) into hgeoHTML
         put fedwiki_ConstructNewPageArray (pageTitle, mapDescription) into pageArray
         --
         put "http://www.openstreetmap.org/#map=" & mZoom & "/" & mLat & "/" & mLon into openstreetmapURL
         put "[[" & pinTitle & "]]"  && "- [" & openstreetmapURL && "openstreetmap]" into mapDescription
         put space & "Also view on" && "- [" & droppedURL && "google]" after mapDescription
         --
         put mLat & comma & mLon && pinTitle into pinLine
         put mapDescription & CR & pinLine into mapText
         --
         pageArray_AddMap pageArray, mlat, mlon, mapText, mZoom
         pageArray_CleanJournal pageArray
         --
         put json_FromArray (pageArray) into pageJSON
         fedwiki_ReturnJSON pageJSON
         break
      default
         -- for now let's assume it's a geo-located image
         put "Write a description of the image here...." into imageDescription
         
         set the itemdelimiter to "."
         -- https://lh3.googleusercontent.com/
         if item 2 of droppedURL = "googleusercontent" then
            put fedwiki_ConstructMapAndImagePageArray (droppedURL, imageDescription) into pageArray
            put json_FromArray (pageArray) into pageJSON
            fedwiki_ReturnJSON pageJSON
         else if item -1 of droppedURL is among the items of "jpg.jpeg.png.giff" then
            put fedwiki_ConstructMapAndImagePageArray (droppedURL, imageDescription) into pageArray
            put json_FromArray (pageArray) into pageJSON
            fedwiki_ReturnJSON pageJSON
         else
            fedwiki_ExitAndReturnError "Nothing dropped", "Error"
         end if
   end switch
end index

function fedwiki_OpenStreetMapPageArray pageTitle, mlat, mlon, mZoom, pMapDescription, pPinTitle
   -- this is for a map drop from openstreetmap or equivalent
   if pPinTitle is empty then put pageTitle into pinTitle
   
   put geo_ConstructHgeo (mlon, mlat, plonDisplay, platDisplay) into hgeoHTML
   
   -- create a page and description
   put fedwiki_ConstructNewPageArray (pageTitle, pMapDescription) into pageArray
   --
   if pPinTitle is not empty then
      put pageTitle into pPinTitle
      put mLat & comma & mLon && pPinTitle into pinLine
      put CR & pinLine after mapText
   end if
   pageArray_AddMap pageArray, mlat, mlon, pMapDescription, mZoom
   
   pageArray_CleanJournal pageArray
   return pageArray
end fedwiki_OpenStreetMapPageArray

function fedwiki_ConstructMapAndImagePageArray imageURL, imageDescription
   -- this is for a geolocated image drop
   put "Map Test" into pageTitle
   put "Pin Test" into pinTitle
   put "This is a test map" into locationDescription
   
   rig_AssetFetchAndSaveImage imageURL, true
   put the result into resultArray
   put resultArray ["imagePath"] into imagePath
   put resultArray ["assetURL"] into assetURL
   put resultArray ["exifArray"] into exifArray
   exif_ExtractLatLong exifArray, mlat, mlon
   
   -- create a page and description
   put "Here is a newly imported image. You can find the original here" into imageCaption
   if exifArray is an array then
      put CR & "<p>" & CR & geo_ConstructHgeo (mlon, mlat) after imageCaption
   end if
   
   put fedwiki_ConstructNewPageArray (pageTitle, imageDescription) into pageArray
   
   -- add the image
   put fedwiki_ConstructImageHtml (assetURL, imageCaption, assetURL, "- source") into imageHTML
   pageArray_AddHtml pageArray, imageHTML
   
   -- if there is GPS info add a map
   if exifArray is an array then
      put 16 into mZoom
      --
      put "http://www.openstreetmap.org/#map=" & mZoom & "/" & mLat & "/" & mLon into openstreetmapURL
      put "[[" & item 1 of locationDescription & "]]" into item 1 of locationDescription
      put locationDescription && "- [" & openstreetmapURL && "openstreetmap]" into mapDescription
      --
      put mLat & comma & mLon && pinTitle into pinLine
      put CR & pinLine after mapText
      --
      pageArray_AddMap pageArray, mlat, mlon, mapText, mZoom
   else
      put "Image Test" into pageArray ["title"]
   end if
   
   pageArray_CleanJournal pageArray
   return pageArray
end fedwiki_ConstructMapAndImagePageArray

function geo_ConstructHgeo mlon, mlat, plonDisplay, platDisplay
   /*
   <p class="h-geo">
   <data class="p-longitude" value="-27.116667">27ÔøΩ 7' 0'' S</data>,
   <data class="p-latitude" value="-109.366667">109ÔøΩ 22' 0'' W</data>
   </p>
   */
   
   if plonDisplay is empty then put geo_LongToDms (mlat) into plonDisplay
   if platDisplay is empty then put geo_LatToDms (mlon) into platDisplay
   
   put "<p class 'h-geo'>" & CR into htmlTemplate
   put "<data class='p-longitude' value='[[mlon]]'>[[plonDisplay]]</data>," & CR after htmlTemplate
   put "<data class='p-latitude' value='[[mlat]]'>[[platDisplay]]</data>" & CR after htmlTemplate
   put "</p>" after htmlTemplate
   put merge (htmlTemplate) into someHTML
   return someHTML
end geo_ConstructHgeo

function geo_LatToDms decValue
   --    <data class="p-latitude" value="-109.366667">109ÔøΩ 22? 0? W</data>
   -- put "-109.366667" into decValue
   
   if decValue > 0 then
      put "E" into westOrEast
   else
      put -1 * decValue into decValue
      put "W" into westOrEast
   end if
   put geo_DecToDms (decValue, westOrEast) into dms
   return dms
end geo_LatToDms

function geo_LongToDms decValue
   --  <data class="p-longitude" value="-27.116667">27ÔøΩ 7? 0? S</data>,
   -- put "-27.116667" into decValue
   
   if decValue > 0 then
      put "N" into westOrEast
   else
      put -1 * decValue into decValue
      put "S" into northOrSouth
   end if
   put geo_DecToDms (decValue, northOrSouth) into dms
   return dms
end geo_LongToDms

private function geo_DecToDms decValue, nwse
   put trunc (decValue) into someDegrees
   subtract someDegrees from decValue
   put decValue * 60 into minuteValue
   put trunc (minuteValue) into someMinutes
   subtract someMinutes from minuteValue
   put minuteValue * 60 into secondsValue
   put trunc (secondsValue) into someSeconds
   
   put someDegrees & "&deg;" && someMinutes & "&apos;" && someSeconds & "&apos;" & "&apos;" && nwse into dms
   return dms
end geo_DecToDms

function geo_DmsToDecimal someDegrees, someMinutes, someSeconds, nwse
   put someDegrees + someMinutes / 60 + someSeconds / 3600 into decValue
   geo_SetNegative decValue, nwse
   return decValue
end geo_DmsToDecimal

command geo_SetNegative @decValue, nwse
   if char 1 of nwse is among the items of "w,s" then
      put -1 * decValue into decValue
   end if
end geo_SetNegative

command geo_ParseGeoStuff geoStuff, @nwse, @someDegrees, @someMinutes, @someSeconds
   set the itemdelimiter to "_"  
   repeat with ii =1 to 4
      -- repeat 4 -- bug: server does not deal with repeat loop properly !!!
      put item 1 of geoStuff into someNum
      delete item 1 of geoStuff
      --
      if someNum is not a number then
         put someNum into nwse
         --
         set the itemdelimiter to comma
         put item 1 of decimalTimeItems into someDegrees
         put item 2 of decimalTimeItems into someMinutes
         put item 3 of decimalTimeItems into someSeconds
         return geoStuff
      else
         put someNum & comma after decimalTimeItems
      end if
   end repeat
   --
   put pageArray_Construct ("Should not exit here", ii && geoStuff) into pageArray
   fedwiki_ReturnPageArray pageArray
end geo_ParseGeoStuff

command geo_ExtractLatLong geoStuff, @decLat, @decLong, @regionInfo
   geo_ParseGeoStuff geoStuff, nwse, someDegrees, someMinutes, someSeconds
   put the result into trimmedGeoStuff
   put geo_DmsToDecimal (someDegrees, someMinutes, someSeconds, nwse) into decLat
   --
   geo_ParseGeoStuff trimmedGeoStuff, nwse, someDegrees, someMinutes, someSeconds
   put the result into regionInfo
   put geo_DmsToDecimal (someDegrees, someMinutes, someSeconds, nwse) into decLong
   return true
end geo_ExtractLatLong
