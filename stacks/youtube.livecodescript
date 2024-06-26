﻿script "youtube.lc" with behavior "behavior_RigLocalOveride"
getprop dep_StackNames
   return "lib_Fedwiki,lib_PageArray,lib_Scrape,lib_Vimeo,lib_Youtube,model_PageArray"
end dep_StackNames

on index
   put transport_DroppedUrl ($_POST_RAW) into droppedURL
   put index_GetPageArray (droppedURL) into pageArray
   transport_ReturnPageArray pageArray
end index

on vimeo
   put transport_DroppedUrl ($_POST_RAW) into droppedURL
   --
   put vimeo_GetPageArray (droppedURL) into pageArray
   --
   transport_ReturnPageArray pageArray
end vimeo

on transport_Video
   -- this is used by onetab.lc
   -- should enhance to return smaller "video paragraphs"
   
   put fedwiki_ProcessPost() into linkURL
   switch
      case linkURL is empty
         put "This is not a youtube video." into errorText
         put CR & CR & $_POST_RAW after errorText
         put pageArray_Construct ("Error: linkURL is empty", errorText) into pageArray
         transport_ReturnPageArray pageArray
         break
      case matchText (linkURL, "https\://www\.youtube\.com/watch\?v\=(.+)", videoID)
         -- "https://www.youtube.com/watch?v="
         put youtube_FetchVideoPageArray (videoID) into fedwikiPageArray
         transport_ReturnPageArray fedwikiPageArray
         break
      case matchText (linkURL, "https\://www\.ted\.com/talks/(.+)", tedID)
         -- https://www.ted.com/talks/jimmy_wales_on_the_birth_of_wikipedia
         put ted_ConstructPageArray (tedID) into fedwikiPageArray
         transport_ReturnPageArray fedwikiPageArray
         break
      case matchText (linkURL, "https\://vimeo\.com/(.+)", vimeoID)
         put vimeo_ConstructPageArray (vimeoID) into fedwikiPageArray
         transport_ReturnPageArray fedwikiPageArray
         break
      default
         put "This is not a youtube video. LinkURL =" && linkURL into errorText
         put pageArray_Construct ("Error", errorText) into pageArray
         transport_ReturnPageArray pageArray
   end switch
end transport_Video

on fetchThumb
   _DeconstructDroppedURL $_POST_RAW, droppedURL, droppedHtml
   put youtube_ParseThumbUrl (droppedURL) into pageJSON
   transport_ReturnJSON pageJSON
end fetchThumb

on fetchAll
   _DeconstructDroppedURL $_POST_RAW, droppedURL, droppedHtml
   put youtube_ParseAllDropUrl (droppedURL) into pageJSON
   transport_ReturnJSON pageJSON
end fetchAll

on recentMarkdown
   _DeconstructDroppedURL $_POST_RAW, droppedURL, droppedHtml
   put youtube_ListAllDropUrl (droppedURL, "recentFirst", true, true) into pageJSON
   transport_ReturnJSON pageJSON
end recentMarkdown

on oldestFirst
   _DeconstructDroppedURL $_POST_RAW, droppedURL, droppedHtml
   put youtube_ListAllDropUrl (droppedURL, "oldestFirst") into pageJSON
   transport_ReturnJSON pageJSON
end oldestFirst

on recentFirst
   _DeconstructDroppedURL $_POST_RAW, droppedURL, droppedHtml
   put youtube_ListAllDropUrl (droppedURL, "recentFirst") into pageJSON
   transport_ReturnJSON pageJSON
end recentFirst

on oldestBullets
   _DeconstructDroppedURL $_POST_RAW, droppedURL, droppedHtml
   put youtube_ListAllDropUrl (droppedURL, "oldestFirst", false) into pageJSON
   transport_ReturnJSON pageJSON
end oldestBullets

on recentBullets
   _DeconstructDroppedURL $_POST_RAW, droppedURL, droppedHtml
   put youtube_ListAllDropUrl (droppedURL, "recentFirst", false) into pageJSON
   transport_ReturnJSON pageJSON
end recentBullets

function index_GetPageArray droppedURL
   set the itemdelimiter to "."
   switch
      case droppedURL begins with "https://vimeo.com/"
         put vimeo_GetPageArray (droppedURL) into pageArray
         break
      case item -1 of droppedURL is among the items of "m4v.mp4.webm"
         put item -1 of droppedURL into mType
         switch mType
            case "m4v"
               put "mp4" into mType
               break
               put  tolower (mType) into mType
         end switch
         
         put "HTML5" && mType into videoType
         set the itemdelimiter to slash
         put item 3 of droppedURL into kWord
         replace "www." with empty in kWord
         put "Imported video" && "- [" & droppedURL && kWord & "]" into videoDescription
         pageArray_AddVideo pageArray, droppedURL, videoType, videoDescription
         break
      case droppedURL begins with "https://www.youtube.com/"
         put youtube_ParseDropUrl (droppedURL) into pageJSON
         put json_ToArray(pageJSON) into pageArray
         break
      case matchText (droppedURL, "https\://www\.ted\.com/talks/(.+)", tedID)
         -- https://www.ted.com/talks/jimmy_wales_on_the_birth_of_wikipedia
         put ted_ConstructPageArray (tedID) into fedwikiPageArray
         break
      default
         put pageArray_Construct ("Error", "The url was not a video url that i recognise!") into pageArray
   end switch
   return pageArray
end index_GetPageArray

function vimeo_GetPageArray droppedURL
   -- put 282295938 into vimeoID
   if matchText (droppedURL, "https\://vimeo\.com/(.+)", vimeoID) then
      put vimeo_ConstructPageArray (vimeoID) into pageArray
   else
      put "This is not a Vimeo video. URL =" && droppedURL into errorText
      put pageArray_Construct ("Error", errorText) into pageArray
   end if
   return pageArray
end vimeo_GetPageArray

function youtube_ParseDropUrl droppedURL
   set the itemdelimiter to "/"
   put item 3 of droppedURL into youtubeBit
   put item 4 of droppedURL into switchOrArray
   put item 5 of droppedURL into extraBit
   
   if youtubeBit is not "www.youtube.com" then
      put "Not a link that I can parse:" && droppedURL into errorText
      put pageArray_Construct ("Error", errorText) into pageArray
      transport_ReturnPageArray pageArray
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
         -- https://www.youtube.com/watch?v=ElH0R__QMXk&t=50s
         
         put youtube_GetVideoID (droppedURL) into videoID
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
         put "Not a link that I can parse." & CR & CR & dropJSON into errorText
         put pageArray_Construct ("Error", errorText) into pageArray
         transport_ReturnPageArray pageArray
   end switch
end youtube_ParseDropUrl

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
         put "Not done users yet for indexes" & CR & CR & dropJSON into errorText
         put pageArray_Construct ("Error", errorText) into pageArray
         transport_ReturnPageArray pageArray
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
         put "Not a link that I can parse." & CR & CR & dropJSON into errorText
         put pageArray_Construct ("Error", errorText) into pageArray
         transport_ReturnPageArray pageArray
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
         put "Not a link that I can parse." & CR & CR & dropJSON into errorText
         put pageArray_Construct ("Error", errorText) into pageArray
         transport_ReturnPageArray pageArray
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
         put "Not a link that I can parse." & CR & CR & dropJSON into errorText
         put pageArray_Construct ("Error", errorText) into pageArray
         transport_ReturnPageArray pageArray
   end switch
end youtube_ParseThumbUrl

command _DeconstructDroppedURL dropJSON, @droppedText, @droppedHtml
   -- changed handler to do something more useful
   put json_ToArray (dropJSON) into dropArray
   put dropArray ["text"] into droppedText
   put dropArray ["html"] into droppedHtml
end _DeconstructDroppedURL
