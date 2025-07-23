script "onetab.lc"
constant ReX = "www.one-tab.com/page/(.+)"

getprop dep_StackNames
   get the env_PathArray of me
   put keys (it) into sNames
   return sNames
   
   get "lib_Fedwiki,lib_OneTab,lib_PageArray"
   return it & ",model_PageArray"
end dep_StackNames

getprop env_PathArray
   put "lcw_Wiki/libraries/lib_Fedwiki.livecode" into dArray ["lib_Fedwiki"]
   put "lcw_Wiki/libraries/lib_OneTab.livecodescript" into dArray ["lib_OneTab"]
   put "lcw_Wiki/libraries/lib_PageArray.livecodescript" into dArray ["lib_PageArray"]
   put "lcw_Wiki/models/model_PageArray.livecodescript" into dArray ["model_PageArray"]
   return dArray
end env_PathArray

getprop dep_Ghurl [sName]
   put the env_PathArray of me into dArray
   return ghurl_FromStackName (sName, rPathArray)
end dep_Ghurl

function ghurl_FromStackName sName, rPathArray
   put "https://livecodeworld.github.io/" into sURL
   put rPathArray [sName] after sURL
   return sURL
end ghurl_FromStackName

getprop page_Array [dUrl]
   oneTab_GetPageArray dUrl
   return the result
end page_Array

on openStack
   put the env_PathArray of me into rPathArray
   deps_LoadAndUse rPathArray
   pass openStack
end openStack

command deps_LoadAndUse rPathArray
   put the stacksinuse into inUse
   repeat for each key sName in rPathArray
      put ghurl_FromStackName (sName, rPathArray) into sURL
      if sName is among the lines of inUse then next repeat
      if exists (stack sName) then
         start using stack sName
      else
         if exists (stack sName) then
            start using stack sName
         else
            go to stack url sURL
            start using stack sName
         end if
      end if
   end repeat
end deps_LoadAndUse

command oneTab_GetPageArray dUrl
   put rex_Construct (ReX) into rExp
   if matchText (dUrl, rExp) then
      put oneTab_FetchPageArray (dUrl) into pArray
   else
      put _ErrorArray() into pArray
   end if
   return pArray
end oneTab_GetPageArray

function rex_Construct sRex
   put "https://" before sRex
   return sRex
end rex_Construct

private function _ErrorArray
   get "Not a [[OneTab]] web page."
   put pageArray_Construct ("Error", it) into pArray
   return pArray
end _ErrorArray


--> Routes
-
on index
   _ReturnPageArray "pretty"
end index

on markdown
   _ReturnPageArray "markdown"
end markdown

on fullfetch
   _ReturnPageArray
end fullfetch

on html
   _ReturnPageArray "htmlSection"
end html

on pretty
   _ReturnPageArray "pretty"
end pretty

on htmlParagraphs
   _ReturnPageArray "htmlParagraphs"
end htmlParagraphs

command _ReturnPageArray
   put transport_DroppedUrl() into someUrl
   put the page_Array [someUrl] of me into pageArray
   transport_ReturnPageArray pageArray
end _ReturnPageArray
