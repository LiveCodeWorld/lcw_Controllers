﻿script "youtube.lc" with behavior "behavior_RigLocalOveride"
getprop dep_StackNames
    return "lib_Fedwiki,lib_Youtube,lib_Scrape"
end dep_StackNames

on index
   put fedwiki_GetDroppedUrl ($_POST_RAW) into droppedURL
   switch
      case droppedURL begins with "https://www.youtube.com/"
         put youtube_ParseDropUrl (droppedURL) into pageJSON
         fedwiki_ReturnJSON pageJSON
         break
      case droppedURL begins with "https://vimeo.com/"
         vimeo
         break
      case matchText (droppedURL, "https\://www\.ted\.com/talks/(.+)", tedID)
         -- https://www.ted.com/talks/jimmy_wales_on_the_birth_of_wikipedia
         put ted_ConstructPageArray (tedID) into fedwikiPageArray
         fedwiki_ReturnPageArray fedwikiPageArray
         break
      default
   end switch
end index

on vimeo
   -- put 282295938 into vimeoID
   put fedwiki_GetDroppedUrl ($_POST_RAW) into droppedURL
   if matchText (droppedURL, "https\://vimeo\.com/(.+)", vimeoID) then
      put vimeo_ConstructPageArray (vimeoID) into fedwikiPageArray
      fedwiki_ReturnPageArray fedwikiPageArray
   else
      put "This is not a Vimeo video. URL =" && droppedURL into errorText
      put fedwiki_ConstructErrorJSON (errorText, "Error") into errorJSON
      fedwiki_ReturnJSON errorJSON
   end if
end vimeo

on transport_Video
   -- this is used by onetab.lc
   -- should enhance to return smaller "video paragraphs"
   
   put fedwiki_ProcessPost() into linkURL
   switch
      case linkURL is empty
         put "This is not a youtube video." into errorText
         put CR & CR & $_POST_RAW after errorText
         put fedwiki_ConstructErrorJSON (errorText, "Error: linkURL is empty") into errorJSON
         fedwiki_ReturnJSON errorJSON
         break
      case matchText (linkURL, "https\://www\.youtube\.com/watch\?v\=(.+)", videoID)
         -- "https://www.youtube.com/watch?v="
         put youtube_FetchVideoPageArray (videoID) into fedwikiPageArray
         fedwiki_ReturnPageArray fedwikiPageArray
         break
      case matchText (linkURL, "https\://www\.ted\.com/talks/(.+)", tedID)
         -- https://www.ted.com/talks/jimmy_wales_on_the_birth_of_wikipedia
         put ted_ConstructPageArray (tedID) into fedwikiPageArray
         fedwiki_ReturnPageArray fedwikiPageArray
         break
      case matchText (linkURL, "https\://vimeo\.com/(.+)", vimeoID)
         put vimeo_ConstructPageArray (vimeoID) into fedwikiPageArray
         fedwiki_ReturnPageArray fedwikiPageArray
         break
      default
         put "This is not a youtube video. LinkURL =" && linkURL into errorText
         put fedwiki_ConstructErrorJSON (errorText, "Error") into errorJSON
         fedwiki_ReturnJSON errorJSON
   end switch
end transport_Video
   
on transportAgain
   put $_POST_RAW into someJSON
   
   put json_ToArray (someJSON) into createArray
   put createArray ["title"] into sectionTitle
   put createArray ["create"]["source"] into sourceArray
   -- put createArray ["create"]["item"]["title"] into parentTitle
   if sourceArray is not an array then
      put fedwiki_ConstructErrorJSON ("This is not create JSON", "Error") into errorJSON
      fedwiki_ReturnJSON errorJSON
      return false
   end if
   
   put sourceArray ["transport"] into transportURL
   put sourceArray ["link_dictionary"] into linkDictionary
   
   put linkDictionary [sectionTitle] into snippetArray
   deconstruct_VideoSnippetArray snippetArray, videoTitle, videoDescription, videoID, thumbNailURL, publishedAt, positionPlusOneNum, tagArray, thumbNailWidth
   
   -- put "OrH6UMYAVsk" into videoID
   put youtube_FetchVideoPageJSON (videoID) into pageJSON
   fedwiki_ReturnJSON pageJSON
end transportAgain
    
on fetchThumb
   _DeconstructDroppedURL $_POST_RAW, droppedURL, droppedHtml
   put youtube_ParseThumbUrl (droppedURL) into pageJSON
   fedwiki_ReturnJSON pageJSON
end fetchThumb
    
on fetchAll
   _DeconstructDroppedURL $_POST_RAW, droppedURL, droppedHtml
   put youtube_ParseAllDropUrl (droppedURL) into pageJSON
   fedwiki_ReturnJSON pageJSON
end fetchAll
    
on recentMarkdown
   _DeconstructDroppedURL $_POST_RAW, droppedURL, droppedHtml
   put youtube_ListAllDropUrl (droppedURL, "recentFirst", true, true) into pageJSON
   fedwiki_ReturnJSON pageJSON
end recentMarkdown
    
on oldestFirst
   _DeconstructDroppedURL $_POST_RAW, droppedURL, droppedHtml
   put youtube_ListAllDropUrl (droppedURL, "oldestFirst") into pageJSON
   fedwiki_ReturnJSON pageJSON
end oldestFirst
    
on recentFirst
   _DeconstructDroppedURL $_POST_RAW, droppedURL, droppedHtml
   put youtube_ListAllDropUrl (droppedURL, "recentFirst") into pageJSON
   fedwiki_ReturnJSON pageJSON
end recentFirst
    
on oldestBullets
   _DeconstructDroppedURL $_POST_RAW, droppedURL, droppedHtml
   put youtube_ListAllDropUrl (droppedURL, "oldestFirst", false) into pageJSON
   fedwiki_ReturnJSON pageJSON
end oldestBullets
    
on recentBullets
   _DeconstructDroppedURL $_POST_RAW, droppedURL, droppedHtml
   put youtube_ListAllDropUrl (droppedURL, "recentFirst", false) into pageJSON
   fedwiki_ReturnJSON pageJSON
end recentBullets
 
function youtube_ParseDropUrl droppedURL
   set the itemdelimiter to "/"
   put item 3 of droppedURL into youtubeBit
   put item 4 of droppedURL into switchOrArray
   put item 5 of droppedURL into extraBit
   
   if youtubeBit is not "www.youtube.com" then
      put "Not a link that I can parse:" && droppedURL into someInfo
      put fedwiki_ConstructErrorJSON (someInfo) into someJSON
      return pageJSON
   end if
   
   put 10 into pMaxResults
   put true into pDontLinkTitle
   
   set the itemdelimiter to "?"
   put item 1 of switchOrArray into switchBit
   switch switchBit
      case "playlist"
         -- https://www.youtube.com/playlist?list=PLPj3KCksGbSY-RaXfrGPnY8uEOl6uylky
         delete item 1 of switchOrArray
         split switchOrArray with "&" and "="
         put switchOrArray ["list"] into playlistID
         
         put "" into pPageTitle
         put youtube_FetchPlayListPageJson (playlistID, pPageTitle, pMaxResults, pDontLinkTitle) into someJSON
         return someJSON
      case "watch"
         -- https://www.youtube.com/watch?v=nU4Ggyobi3k&index=6&list=PLPj3KCksGbSY-RaXfrGPnY8uEOl6uylky
         delete item 1 of switchOrArray
         split switchOrArray with "&" and "="
         put switchOrArray ["v"] into videoID
         
         put youtube_FetchVideoPageJSON (videoID) into someJSON
         return someJSON
      case "channel"
         -- https://www.youtube.com/channel/UCR9gdpWisRwnk_k23GsHfcA
         put extraBit into channelID
         put youtube_FetchChannelUploadPageJson (channelID, pMaxResults, pDontLinkTitle) into someJSON
         return someJSON
      case "user"
         put false into pDontLinkTitle
         put extraBit into userName
         put youtube_FetchUserUploadPageJson (userName, pMaxResults, pDontLinkTitle) into someJSON
         return someJSON
      default
         put "Not a link that I can parse." & CR & CR & dropJSON into someInfo
         put fedwiki_ConstructErrorJSON (someInfo) into someJSON
         return someJSON
   end switch
end youtube_ParseDropUrl

/*
function youtube_FetchNextPageJson droppedURL, droppedHtml
   put fedwiki_FetchMetadataArray (droppedURL) into metadataArray
   put metadataArray ["pageTitle"] into pageTitle
   put metadataArray ["author"] into transporterName
   put metadataArray ["nextPageToken"] into nextPageToken
   
   if nextPageToken is empty then
      put "Not a link that I can parse:" && droppedURL & CR & CR & droppedHtml into someInfo
      put fedwiki_ConstructErrorJSON (someInfo) into someJSON
   else -- dropped a Fedwiki page which has a nextPageToken
      put 10 into pMaxResults
      put true into pDontLinkTitle
      put wcn_GetChannelID() into channelID
      
      put youtube_FetchChannelUploadPageJson (channelID, pMaxResults, pDontLinkTitle, nextPageToken) into someJSON
   end if
   return someJSON
end youtube_FetchNextPageJson
*/

function youtube_ListAllDropUrl droppedURL, pDirection, pNumbered
   put false into pDontLinkTitle
   
   set the itemdelimiter to "/"
   put item 3 of droppedURL into youtubeBit
   put item 4 of droppedURL into switchOrArray
   put item 5 of droppedURL into extraBit
   
   set the itemdelimiter to "?"
   put item 1 of switchOrArray into switchBit
   switch switchBit
      case "user"
         put "Not done users yet for indexes" & CR & CR & dropJSON into someInfo
         put fedwiki_ConstructErrorJSON (someInfo) into someJSON
         return someJSON
      case "channel"
         put extraBit into channelID
         put youtube_FetchChannelIndexPageJson (channelID) into pageJSON
         return pageJSON
      case "playlist"
         delete item 1 of switchOrArray
         split switchOrArray with "&" and "="
         put switchOrArray ["list"] into playlistID
         
         put empty into pPageTitle
         put youtube_FetchPlayListIndexPageJson  (playlistID, pPageTitle, pDirection, pNumbered, droppedURL) into pageJSON
         return pageJSON
      default
         put "Not a link that I can parse." & CR & CR & dropJSON into someInfo
         put fedwiki_ConstructErrorJSON (someInfo) into someJSON
         return someJSON
   end switch
end youtube_ListAllDropUrl
 
function youtube_ParseAllDropUrl droppedURL
   put false into pDontLinkTitle
   
   set the itemdelimiter to "/"
   put item 3 of droppedURL into youtubeBit
   put item 4 of droppedURL into switchOrArray
   put item 5 of droppedURL into extraBit
   
   set the itemdelimiter to "?"
   put item 1 of switchOrArray into switchBit
   switch switchBit
      case "playlist"
         delete item 1 of switchOrArray
         split switchOrArray with "&" and "="
         put switchOrArray ["list"] into playlistID
         
         put "" into pPageTitle
         put youtube_FetchAllPlayListPageJson (playlistID, pPageTitle, pDontLinkTitle) into pageJSON
         return pageJSON
      case "channel"
         -- put wcn_GetChannelID() into channelID
         put extraBit into channelID
         put youtube_FetchAllChannelUploadPageJson (channelID, false) into someJSON
         return someJSON
      case "user"
         put extraBit into userName
         put youtube_FetchAllUserUploadPageJson (userName, pDontLinkTitle) into someJSON
         return someJSON
      case "watch" -- only one thing anyway
         delete item 1 of switchOrArray
         split switchOrArray with "&" and "="
         put switchOrArray ["v"] into videoID
         
         put youtube_FetchVideoPageJSON (videoID) into someJSON
         return someJSON
      default
         put "Not a link that I can parse." & CR & CR & dropJSON into someInfo
         put fedwiki_ConstructErrorJSON (someInfo) into someJSON
         return someJSON
   end switch
end youtube_ParseAllDropUrl
 
function youtube_ParseThumbUrl droppedURL
   set the itemdelimiter to "/"
   put item 3 of droppedURL into youtubeBit
   put item 4 of droppedURL into switchOrArray
   put item 5 of droppedURL into extraBit
   
   set the itemdelimiter to "?"
   put item 1 of switchOrArray into switchBit
   switch switchBit
      case "playlist"
         delete item 1 of switchOrArray
         split switchOrArray with "&" and "="
         put switchOrArray ["list"] into playlistID
         
         return pageJSON
      case "channel"
         put extraBit into channelID
         
         return pageJSON
      case "user"
         put extraBit into userName
         
         return someJSON
      case "watch" -- only one thing anyway
         delete item 1 of switchOrArray
         split switchOrArray with "&" and "="
         put switchOrArray ["v"] into videoID
         
         put youtube_FetchVideoThumbPageJSON (videoID) into someJSON
         return someJSON
      default
         put "Not a link that I can parse." & CR & CR & dropJSON into someInfo
         put fedwiki_ConstructErrorJSON (someInfo) into someJSON
         return someJSON
   end switch
end youtube_ParseThumbUrl

command _DeconstructDroppedURL dropJSON, @droppedText, @droppedHtml
   -- changed handler to do something more useful
   put json_ToArray (dropJSON) into dropArray
   put dropArray ["text"] into droppedText
   put dropArray ["html"] into droppedHtml
end _DeconstructDroppedURL