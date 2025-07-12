script "onetab.lc"
constant ReX = "www.one-tab.com/page/(.+)"

getprop page_Array [dUrl]
  oneTab_GetPageArray dUrl
  return the result
end page_Array

command oneTab_GetPageArray dUrl
  put rex_Construct (ReX) into rExp
  if matchText (dUrl, rExp) then
    put oneTab_FetchPageArray (dUrl) into pArray
  else
    put _ErrorArray() into pArray
  end if
  return pArray
end oneTab_GetPageArray

getprop dep_StackNames
  get "lib_Fedwiki,lib_OneTab,lib_PageArray"
  return it & ",model_PageArray"
end dep_StackNames

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
