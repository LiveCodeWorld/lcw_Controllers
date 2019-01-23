script "imagine.lc" with behavior "behavior_RigLocalOveride"
getprop dep_StackNames
   return "lib_Fedwiki,lib_MediaWiki,lib_FedWikiPedia,lib_HTML,lib_Scrape,lib_REST,lib_Citation"
end dep_StackNames

on index
   put fedwiki_GetDroppedUrl() into droppedURL
   
   switch
      case droppedURL begins with "https://www.listennotes.com/podcasts/"
         fedwiki_ForwardAndReturn "https://rest.livecode.world/bbc/listenNotes"
         break
      case droppedURL begins with "https://player.fm/series/"
         fedwiki_ForwardAndReturn "https://rest.livecode.world/bbc/playerfm"
         break
      case droppedURL begins with "http://www.radiolab.org/story/"
      case droppedURL begins with "http://www.bbc.co.uk/programmes/"
      case droppedURL begins with "https://www.theguardian.com/science/audio/" -- plenty of other podcast urls
         fedwiki_ForwardAndReturn "https://rest.livecode.world/bbc"
         break
      case droppedURL ends with ".json"
         fedwiki_ForwardAndReturn "https://rest.livecode.world/paper/paper_from_wiki"
         break
      case matchText (droppedURL, "https://paper.dropbox.com/doc/(.+)--([^-]+)-(.+)", docTitleBit, probUserID, docID)
         fedwiki_ForwardAndReturn "https://rest.livecode.world/paper"
         break
      case matchText (droppedURL, "https://app.asana.com/0/(.+)/(.+)", projectID, taskID)
         fedwiki_ForwardAndReturn "https://rest.livecode.world/asana"
         break
      case droppedURL begins with "https://www.youtube.com/"
      case droppedURL begins with "https://vimeo.com/"
      case droppedURL begins with "https://www.ted.com/talks/"
         fedwiki_ForwardAndReturn "https://rest.livecode.world/youtube"
         break
      case droppedURL begins with "https://audioboom.com/posts/"
         fedwiki_ForwardAndReturn "https://rest.livecode.world/audioboom"
         break
      case droppedURL begins with "http://www.openstreetmap.org/"
      case droppedURL begins with "https://www.openstreetmap.org/"
      case droppedURL begins with "https://www.google.co.uk/maps/place/"
      case droppedURL begins with "https://www.google.com/maps/place/"
      case matchtext (droppedURL, "^https://tools.wmflabs.org/geohack/geohack.php\?pagename=(.+)&params=(.+)", pageName, geoInfo)
         fedwiki_ForwardAndReturn "https://rest.livecode.world/map"
         break
      case matchText (droppedURL, "https://www.one-tab.com/page/(.+)", oneTabID)
         fedwiki_ForwardAndReturn "https://rest.livecode.world/onetab"
         break
      case matchText (droppedURL, "https://rationalwiki.org/wiki/(.+)", wikiSlug)
      case matchText (droppedURL, "http://wiki.p2pfoundation.net/(.+)", wikiSlug)
      case matchText (droppedURL, "https://www.explainxkcd.com/wiki/index.php/(.+)", wikiSlug)
      case matchText (droppedURL, "https://(.+).bitcoin.it/wiki/(.+)", wikiLanguage, wikiSlug)
      case matchText (droppedURL, "https://(.+).wikipedia.org/(.+)", lastBit)
         fedwiki_ForwardAndReturn "https://rest.livecode.world/mediawiki"
         break
      case matchtext (droppedURL, "https://matrix.org/_matrix/media/v1/download/matrix.org/(.+)", matrixAssetID)
      case matchText (droppedURL, "http://britishlibrary.typepad.co.uk/.a/(.+)", assetID)
      case matchText (droppedURL, "https://static.+.squarespace.com/static/.+", photoID)
         fedwiki_ForwardAndReturn "http://home.c2.com:4010/image"
         -- photo droppedURL
         break
      case matchText (droppedURL, "https://www.pinterest.com/pin/(.+)/|https://www.pinterest.co.uk/pin/(.+)/", photoID)
         fedwiki_ForwardAndReturn "https://rest.livecode.world/pinterest"
         break
      case matchText (droppedURL, "https://www.flickr.com/photos/(.+)/(.+)/in/.+", userID, photoID)
         fedwiki_ForwardAndReturn "https://rest.livecode.world/flickr"
         break
      case matchText (droppedURL, "https://twitter.com/.+/status/.+")
         fedwiki_ForwardAndReturn "https://rest.livecode.world/twitter"
         break
      case droppedURL begins with "https://www.google.com/imgres?imgurl="
      case droppedURL begins with "https://www.google.co.uk/imgres?imgurl="
         googleImage
         break
      case fedwiki_IsFaviconDrop()
         favicon
         break
      case item -1 of droppedURL is among the items of "jpg.jpeg.png.gif.webp"
         photo
         break
      default
         put scrape_ConstructFedwikiPageArray (droppedURL, true, true, true) into pageArray
         fedwiki_ReturnPageArray pageArray
   end switch
end index

command favicon
   -- already checked with "fedwiki_IsFaviconDrop"
   fedwiki_SetDroppedFaviconInfo pageSlug, fedwikiDomain
   if the result is true then
      put "https://rest.livecode.world/mediawiki/search" into restURL
      put fedwiki_EncodePost (pageSlug) into postJSON
      fedwiki_PostJSON postJSON, restURL
      --
      put the result into pageJSON
      fedwiki_ReturnJSON pageJSON
   else
      put "The web page for url" && droppedURL && "is not one that I can parse." & CR & CR & $_POST_RAW into someInfo
      put fedwiki_ConstructErrorJSON (someInfo) into someJSON
      fedwiki_ReturnJSON someJSON
   end if
end favicon

on photo
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
end photo

command googleImage
   put fedwiki_GetDroppedUrl() into googleURL
   put google_ConstructFedwikiImagePageArray (googleURL) into fedwikiPageArray
   fedwiki_ReturnPageArray fedwikiPageArray
end googleImage
