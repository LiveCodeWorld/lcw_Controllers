script "render.lc"
getprop dep_StackNames
   return "lib_Fedwiki,lib_Scrape"
end dep_StackNames

on index
   put http_GetRequestArray() into requestArray
   --
   switch $REQUEST_METHOD
      case "GET"
         /*
         put "thought.garden" into someDomain
         put "memebase" into someSlug
         put "e61f79226f7bbf65" into itemID
         */
         put requestArray ["httpGetParams"] into paramArray
         put paramArray ["domain"] into someDomain
         put paramArray ["slug"] into someSlug
         put paramArray ["itemID"] into itemID
         put paramArray ["format"] into someFormat
         --
         switch someFormat
            case "html"
               put fedwiki_ConstrulHtmlUrl (someDomain, someSlug) into htmlUrl
               put url htmlUrl into pageHTML
               if itemID is empty then
                  put pageHTML
               else
                  -- unfortunately the html rendering does not return div ids (the wiki client html provides this)
                  -- at the moment we just get the "story" div
                  put scrape_GetDiv (pageHTML, "class", "story") into pageHTML
                  put pageHTML
               end if
               break
            case "json"
               put fedwiki_FetchPageJson (someDomain, someSlug, itemID) into someJSON
               put someJSON
               break
            default
               -- case "markdown-item"
               put token 1 of someFormat into itemType
               -- let's fetch and return the markdown plugin json
               put fedwiki_FetchFirstItemText (someDomain, someSlug, itemType) into itemText
               -- then render it ourselves
               put itemText
         end switch 
         break
      default
         -- case "POST"
         -- a transporter
         break
         put fedwiki_GetDroppedUrl ($_POST_RAW) into someUrl
         put someUrl into someJSON
         fedwiki_ReturnJSON someJSON
         break
      default
   end switch
end index

function fedwiki_FetchPageJson someDomain, someSlug, pItemID
   -- fetch entire page json or just an individual item ()by item id)
   put fedwiki_ConstructJsonUrl (someDomain, someSlug) into jsonUrl
   put url jsonUrl into pageJSON
   if pItemID is empty then
      put pageJSON into someJSON
   else
      put fedwiki_ExtractJsonItem (pItemID, pageJSON) into someJSON
   end if
   return someJSON
end fedwiki_FetchPageJson

function fedwiki_ConstrulHtmlUrl someDomain, someSlug, pHttpBit
   if pHttpBit is empty then put "http" into pHttpBit
   put merge ("[[pHttpBit]]://[[someDomain]]/[[someSlug]].html") into htmlUrl
   return htmlUrl
end fedwiki_ConstrulHtmlUrl

function fedwiki_ConstructJsonUrl someDomain, someSlug, pHttpBit
   if pHttpBit is empty then put "http" into pHttpBit
   put merge ("[[pHttpBit]]://[[someDomain]]/[[someSlug]].json") into jsonUrl
   return jsonUrl
end fedwiki_ConstructJsonUrl

function http_GetRequestArray
   if the environment is not "server" then
      put "GET" into $REQUEST_METHOD
      -- put "/echo?domain=thought.garden&slug=memebase&itemid=e61f79226f7bbf65&format=html" into $REQUEST_URI
      -- put "/echo?domain=thought.garden&slug=memebase&format=html" into $REQUEST_URI
      -- put "/render?domain=thought.garden&slug=memebase&format=json" into $REQUEST_URI
      -- put "/render?domain=thought.garden&slug=memebase&format=html&itemid=e61f79226f7bbf65" into $REQUEST_URI
      put "/render?domain=tools.progressivedemocracy.cc&slug=test&format=markdown" into $REQUEST_URI
   end if
   
   put $REQUEST_METHOD into requestArray ["httpMethod"]
   put $REQUEST_URI into getParams
   --
   set the itemdelimiter to "?"
   put item 1 of getParams into getRoute
   delete char 1 of getRoute
   put getRoute into requestArray ["httpRoute"]
   delete item 1 of getParams
   --
   split getParams by "&" and "="
   put getParams into requestArray ["httpGetParams"]
   return requestArray
end http_GetRequestArray

function fedwiki_FetchFirstItemText someDomain, someSlug, pItemType
   -- fetch entire page json or just an individual item ()by item id)
   put fedwiki_ConstructJsonUrl (someDomain, someSlug) into jsonUrl
   put url jsonUrl into pageJSON
   put json_ToArray (pageJSON) into pageArray
   --
   put fedwiki_ExtractFirstItemArray (pageArray, pItemType) into itemArray
   put itemArray ["text"] into itemText
   return itemText
end fedwiki_FetchFirstItemText

function fedwiki_FetchFirstItemJson someDomain, someSlug, pItemType
   -- fetch entire page json or just an individual item ()by item id)
   put fedwiki_ConstructJsonUrl (someDomain, someSlug) into jsonUrl
   put url jsonUrl into pageJSON
   put json_ToArray (pageJSON) into pageArray
   --
   put fedwiki_ExtractFirstItemArray (pageArray, pItemType) into itemArray
   put json_FromArray (itemArray) into itemJSON
   return itemJSON
end fedwiki_FetchFirstItemJson

function fedwiki_ExtractJsonItem itemID, pageJSON
   put json_ToArray (pageJSON) into pageArray
   put fedwiki_ExtractItemArray (itemID, pageArray) into itemArray
   if itemArray is not an array then return empty
   
   put json_FromArray (itemArray) into itemJSON
   return itemJSON
end fedwiki_ExtractJsonItem
   
function fedwiki_ExtractFirstItemArray pageArray, pItemType
   if pItemType is empty then 
      put pageArray ["story"][1] into itemArray
      return itemArray
   end if
   
   put pageArray ["story"] into storyArray
   repeat for each key itemNum in storyArray
      put storyArray [itemNum] into itemArray
      if itemArray ["type"] = pItemType then
         return itemArray 
      end if
   end repeat
   return empty
end fedwiki_ExtractFirstItemArray

function fedwiki_ExtractItemArray itemID, pageArray
   put pageArray ["story"] into storyArray
   repeat for each key itemNum in storyArray
      put storyArray [itemNum] into itemArray
      if itemArray ["id"] = itemID then
         return itemArray 
      end if
   end repeat
   return empty
end fedwiki_ExtractItemArray
