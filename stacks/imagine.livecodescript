﻿script "imagine.lc" with behavior "behavior_RigLocalOveride"
getprop dep_StackNames
    return "lib_Fedwiki"
end dep_StackNames

on index   
   transport_DropTest droppedURL, srcImageURL, qEnd, isFavicon
   put the result into resultArray
   --
   switch
      /*
      case matchtext (droppedURL, "https://matrix.org/_matrix/media/v1/download/matrix.org/(.+)", matrixAssetID)
      case matchText (droppedURL, "http://britishlibrary.typepad.co.uk/.a/(.+)", assetID)
      case matchText (droppedURL, "https://static.+.squarespace.com/static/.+", photoID)
         fedwiki_ForwardAndReturn "http://home.c2.com:4010/image"
         break
         */
      case matchText (droppedURL, "https://www.one-tab.com/page/(.+)", oneTabID)
         fedwiki_ForwardAndReturn "http://rest.livecode.world/onetab"
         break
      case isFavicon
         fedwiki_ForwardAndReturn "http://rest.livecode.world/flag"
         break
      case droppedURL begins with "https://www.listennotes.com/podcasts/"
         fedwiki_ForwardAndReturn "http://rest.livecode.world/podcast"
         break
      case matchText (droppedURL, "https://www.gameb.wiki/index.php\?title=(.+)", wikiSlug)
      case matchText (droppedURL, "https://sterbalssundrystudies.miraheze.org/wiki/(.+)", wikiSlug)
      case matchText (droppedURL, "https://rationalwiki.org/wiki/(.+)", wikiSlug)
      case matchText (droppedURL, "http://wiki.p2pfoundation.net/(.+)", wikiSlug)
      case matchText (droppedURL, "https://www.explainxkcd.com/wiki/index.php/(.+)", wikiSlug)
      case matchText (droppedURL, "https://(.+).bitcoin.it/wiki/(.+)", wikiLanguage, wikiSlug)
      case matchText (droppedURL, "https://commons.wikimedia.org/wiki/(File:.+.webm)", shortVideoFile)
      case matchText (droppedURL, "https://commons.wikimedia.org/wiki/(File:.+)", shortImageFile)
      case matchText (droppedURL, "https://(.+).wikipedia.org/(.+)", lastBit)
         fedwiki_ForwardAndReturn "http://rest.livecode.world/mediawiki"
         break
      case droppedURL begins with "https://www.listennotes.com/podcasts/"
         fedwiki_ForwardAndReturn "http://rest.livecode.world/bbc/listenNotes"
         break
      case droppedURL begins with "https://player.fm/series/"
         fedwiki_ForwardAndReturn "http://rest.livecode.world/bbc/playerfm"
         break
      case droppedURL begins with "http://www.radiolab.org/story/"
      case droppedURL begins with "http://www.bbc.co.uk/programmes/"
      case droppedURL begins with "https://www.bbc.co.uk/programmes/"
      case droppedURL begins with "https://www.theguardian.com/science/audio/" -- plenty of other podcast urls
         fedwiki_ForwardAndReturn "http://rest.livecode.world/bbc"
         break
      case droppedURL ends with ".json"
         fedwiki_ForwardAndReturn "http://rest.livecode.world/paper/paper_from_wiki"
         break
      case matchText (droppedURL, "https://paper.dropbox.com/doc/(.+)--([^-]+)-(.+)", docTitleBit, probUserID, docID)
         fedwiki_ForwardAndReturn "http://rest.livecode.world/paper"
         break
      case matchText (droppedURL, "https://app.asana.com/0/(.+)/(.+)", projectID, taskID)
         fedwiki_ForwardAndReturn "http://rest.livecode.world/asana"
         break
      case droppedURL begins with "https://audioboom.com/posts/"
         fedwiki_ForwardAndReturn "http://rest.livecode.world/audioboom"
         break
      case droppedURL begins with "http://www.openstreetmap.org/"
      case droppedURL begins with "https://www.openstreetmap.org/"
      case droppedURL begins with "https://www.google.co.uk/maps/place/"
      case droppedURL begins with "https://www.google.com/maps/place/"
      case matchtext (droppedURL, "^https://geohack.toolforge.org/geohack.php\?pagename=(.+)&params=(.+)", pageName, geoInfo)
         fedwiki_ForwardAndReturn "http://rest.livecode.world/map"
         break
      case matchText (droppedURL, "https\://vimeo\.com/(.+)", vimeoID)
         -- case droppedURL begins with "https://vimeo.com/"
         fedwiki_ForwardAndReturn "http://rest.livecode.world/vimeo"
         break
      case qEnd is among the items of "mp4,webm,m4v"
      case droppedURL begins with "https://www.youtube.com/"
      case droppedURL begins with "https://www.ted.com/talks/"
         fedwiki_ForwardAndReturn "http://rest.livecode.world/youtube"
         break
      case matchText (droppedURL, "https://www.pinterest.com/pin/(.+)/|https://www.pinterest.co.uk/pin/(.+)/", photoID)
         fedwiki_ForwardAndReturn "http://rest.livecode.world/pinterest"
         break
      case matchText (droppedURL, "https://www.flickr.com/photos/(.+)/(.+)/in/.+", userID, photoID)
         fedwiki_ForwardAndReturn "http://rest.livecode.world/flickr"
         break
      case qEnd is among the items of "jpg,jpeg,png,gif,webp,svg"
         fedwiki_ForwardAndReturn "http://rest.livecode.world/photo"
         break
      case droppedURL begins with "https://www.google.com/imgres?imgurl="
      case droppedURL begins with "https://www.google.co.uk/imgres?imgurl="
         fedwiki_ForwardAndReturn "http://rest.livecode.world/google"
         break
      case matchText (droppedURL, "https://twitter.com/.+/status/.+")
         fedwiki_ForwardAndReturn "http://rest.livecode.world/twitter"
         break
      default
         fedwiki_ForwardAndReturn "http://rest.livecode.world/scrape/htmlPage"
   end switch
end index
