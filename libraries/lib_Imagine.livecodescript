script "lib_Imagine"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_Imagine
type: library
version: 0.1


--> Working on
-
command imagine_AddUrl droppedURL
   switch
      case isFavicon
         controller_Dispatch droppedURL, "flag.lc"
         break
      case matchText (droppedURL, "https://www.one-tab.com/page/(.+)", oneTabID)
         controller_Dispatch droppedURL, "onetab.lc"
         break
      case qEnd is among the items of "jpg,jpeg,png,gif,webp,svg"
         controller_Dispatch droppedURL, "photo.lc"
         break
      case droppedURL begins with "https://www.google.com/imgres?imgurl="
      case droppedURL begins with "https://www.google.co.uk/imgres?imgurl="
         controller_Dispatch droppedURL, "google.lc"
         break
      case matchText (droppedURL, "https://app.asana.com/0/(.+)/(.+)", projectID, taskID)
         controller_Dispatch droppedURL, "asana.lc"
         break
      case droppedURL begins with "http://www.radiolab.org/story/"
      case droppedURL begins with "http://www.bbc.co.uk/programmes/"
      case droppedURL begins with "https://www.bbc.co.uk/programmes/"
      case droppedURL begins with "https://www.theguardian.com/science/audio/" -- plenty of other podcast urls
         controller_Dispatch droppedURL, "bbc.lc"
         break
      case droppedURL begins with "http://www.openstreetmap.org/"
      case droppedURL begins with "https://www.openstreetmap.org/"
      case droppedURL begins with "https://www.google.co.uk/maps/place/"
      case droppedURL begins with "https://www.google.com/maps/place/"
      case matchtext (droppedURL, "^https://geohack.toolforge.org/geohack.php\?pagename=(.+)&params=(.+)", pageName, geoInfo)
         controller_Dispatch droppedURL, "map.lc"
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
         controller_Dispatch droppedURL, "mediawiki.lc"
         break
      case droppedURL ends with ".json"
         fedwiki_ForwardAndReturn "http://rest.livecode.wiki/paper/paper_from_wiki"
         controller_Dispatch droppedURL, "paper.lc", "paper_from_wiki"
         break
      case droppedURL begins with "https://www.listennotes.com/podcasts/"
         fedwiki_ForwardAndReturn "http://rest.livecode.wiki/bbc/listenNotes"
         break
      case droppedURL begins with "https://www.listennotes.com/podcasts/"
         fedwiki_ForwardAndReturn "http://rest.livecode.wiki/podcast"
         break
      case droppedURL begins with "https://player.fm/series/"
         fedwiki_ForwardAndReturn "http://rest.livecode.wiki/bbc/playerfm"
         break
      case matchText (droppedURL, "https://paper.dropbox.com/doc/(.+)--([^-]+)-(.+)", docTitleBit, probUserID, docID)
         fedwiki_ForwardAndReturn "http://rest.livecode.wiki/paper"
         break
      case droppedURL begins with "https://audioboom.com/posts/"
         fedwiki_ForwardAndReturn "http://rest.livecode.wiki/audioboom"
         break
      case matchText (droppedURL, "https\://vimeo\.com/(.+)", vimeoID)
         -- case droppedURL begins with "https://vimeo.com/"
         fedwiki_ForwardAndReturn "http://rest.livecode.wiki/vimeo"
         break
      case qEnd is among the items of "mp4,webm,m4v"
      case droppedURL begins with "https://www.youtube.com/"
      case droppedURL begins with "https://www.ted.com/talks/"
         fedwiki_ForwardAndReturn "http://rest.livecode.wiki/youtube"
         break
      case matchText (droppedURL, "https://www.pinterest.com/pin/(.+)/|https://www.pinterest.co.uk/pin/(.+)/", photoID)
         fedwiki_ForwardAndReturn "http://rest.livecode.wiki/pinterest"
         break
      case matchText (droppedURL, "https://www.flickr.com/photos/(.+)/(.+)/in/.+", userID, photoID)
         fedwiki_ForwardAndReturn "http://rest.livecode.wiki/flickr"
         break
      case matchText (droppedURL, "https://twitter.com/.+/status/.+")
         fedwiki_ForwardAndReturn "http://rest.livecode.wiki/twitter"
         break
      default
         fedwiki_ForwardAndReturn "http://rest.livecode.wiki/scrape/htmlPage"
         controller_Dispatch droppedURL, "scrape.lc", "htmlPage"
   end switch
end imagine_AddUrl

function imagine_ConstructDroppedURLArray droppedURL
   switch
      -- https://www.ted.com/talks/alexander_betts_why_brexit_happened_and_what_to_do_next
      case droppedURL begins with "https://www.youtube.com/"
      case droppedURL begins with "https://vimeo.com/"
      case droppedURL begins with "https://www.ted.com/talks/"
         put platform_RestUrl ("transport_Video") into resultArray ["url"]
         put "transport_Video" into resultArray ["handler"]
         return resultArray
      case droppedURL begins with "https://audioboom.com/posts/"
         put platform_RestUrl ("audioboom") into resultArray ["url"]
         put "transport_AudioBoom" into resultArray ["handler"]
         return resultArray
      case droppedURL begins with "https://player.fm/series/"         
         put platform_RestUrl ("playerfm") into resultArray ["url"]
         put "transport_PlayerFM" into resultArray ["handler"]
         return resultArray
      case droppedURL begins with "http://www.radiolab.org/story/"
      case droppedURL begins with "http://www.bbc.co.uk/programmes/"
      case droppedURL begins with "https://www.theguardian.com/science/audio/" -- plenty of other podcast urls
         put platform_RestUrl ("bbc") into resultArray ["url"]
         put "transport_Podcast" into resultArray ["handler"]
         return resultArray
      case droppedURL begins with "http://www.openstreetmap.org/"
      case droppedURL begins with "https://www.openstreetmap.org/"
      case droppedURL begins with "https://www.google.co.uk/maps/place/"
      case droppedURL begins with "https://www.google.com/maps/place/"
      case matchtext (droppedURL, "^https://tools.wmflabs.org/geohack/geohack.php\?pagename=(.+)&params=(.+)", pageName, geoInfo)
         put platform_RestUrl ("map") into resultArray ["url"]
         put "transport_Map" into resultArray ["handler"]
         return resultArray
      case matchText (droppedURL, "https://www.one-tab.com/page/(.+)", oneTabID)
         put platform_RestUrl ("onetab") into resultArray ["url"]
         put "transport_OneTab" into resultArray ["handler"]
         return resultArray
      case matchText (droppedURL, "https://(.+).wikipedia.org/(.+)", lastBit)
         put platform_RestUrl ("mediawiki") into resultArray ["url"]
         put "transport_Mediawiki" into resultArray ["handler"]
         return resultArray
      case matchtext (droppedURL, "https://matrix.org/_matrix/media/v1/download/matrix.org/(.+)", matrixAssetID)
      case matchText (droppedURL, "http://britishlibrary.typepad.co.uk/.a/(.+)", assetID)
      case matchText (droppedURL, "https://static.+.squarespace.com/static/.+", photoID)
         put "http://home.c2.com:4010/image" into resultArray ["url"]
         put "transport_Photo" into resultArray ["handler"]
         return resultArray
      case matchText (droppedURL, "https://www.pinterest.com/pin/(.+)/|https://www.pinterest.co.uk/pin/(.+)/", photoID)
         put "" into resultArray ["url"]
         put "transport_Pinterest" into resultArray ["handler"]
         return resultArray
      case matchText (droppedURL, "https://www.flickr.com/photos/(.+)/(.+)/in/.+", userID, photoID)
         put "" into resultArray ["url"]
         put "transport_Flickr" into resultArray ["handler"]
         return resultArray
      case matchText (droppedURL, "https://twitter.com/.+/status/.+")
         put "" into resultArray ["url"]
         put "transport_Twitter" into resultArray ["handler"]
         return resultArray
      case droppedURL begins with "https://www.google.com/imgres?imgurl="
      case droppedURL begins with "https://www.google.co.uk/imgres?imgurl="
         put "" into resultArray ["url"]
         put "transport_GoogleImage" into resultArray ["handler"]
         return resultArray
      default
         put "" into resultArray ["url"]
         put "transport_Webpage" into resultArray ["handler"]
         return resultArray
   end switch
end imagine_ConstructDroppedURLArray


--> Brew
-
function brew_ListServices
   put shell ("brew services list") into sResult
   return sResult
end brew_ListServices


--> Imagine
-


--> Deps
-
