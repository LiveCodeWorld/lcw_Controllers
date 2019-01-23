script "mw_image.lc"
command index
   put $_POST_RAW into dropJSON
   put json_ToArray (dropJSON) into dropArray
   put dropArray ["text"] into droppedURL
   
   put mediwiki_ExtractImageFileFromUrl (droppedURL) into shortImageFile
   -- put "Andalusian_horse_moscow.jpg" into shortImageFile
   
   put fedwiki_FetchWikiMediaPageJson (shortImageFile) into someJSON
   if someJSON is empty then
      put "Error, this was not an mediawiki image url" into errorText
      put fedwiki_ConstructErrorJSON (errorText) into someJSON
   end if
   
   put new header "Content-Type: application/json; charset=utf-8"
   put new header "Access-Control-Allow-Origin: *"
   put new header "Access-Control-Allow-Headers: Accept, Authorization, Content-Type"
   put new header "Access-Control-Allow-Methods: GET, POST, PUT, PATCH, DELETE OPTIONS, LINK, UNLINK"
   put someJSON
end index
