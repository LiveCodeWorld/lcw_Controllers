script "onetab.lc"
getprop dep_StackNames
   return "lib_Fedwiki,lib_OneTab,lib_PageArray,model_PageArray"
end dep_StackNames

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

command _ReturnPageArray pType
   put fedwiki_GetDroppedUrl() into someUrl
   if someUrl begins with "https://www.one-tab.com" then
      put oneTab_FetchPageArray (someUrl, pType) into pageArray
   else
      put "Not a [[OneTab]] web page. Visit OneTab to start collaborative bookmarking - [https://www.one-tab.com/ one-tab.com]" into someInfo
      put pageArray_Construct ("Error", someInfo) into pageArray
   end if
   fedwiki_ReturnPageArray pageArray
end _ReturnPageArray
