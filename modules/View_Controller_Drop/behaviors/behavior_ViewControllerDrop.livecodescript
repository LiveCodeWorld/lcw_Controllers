script "behavior_ViewControllerDrop"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: behavior_ViewControllerDrop
type: behavior
version: 0.1


--> Events
-
on mouseUp
   dragDrop
end mouseUp


--> Events | Drag
-
command drop_WikiHtmlUrl wikiHtmlURl
   --http://david.dojo.fed.wiki/today-i-write.html
   
   put "http://(.+)\/(.+)\.html" into someReg
   if matchText (wikiHtmlURl, someReg, wikiDomain, pageSlug) is true then
   else
      return empty
   end if
end drop_WikiHtmlUrl


--> Events | Drag
-
on dragDrop
   -- drop_WikiHtmlUrl
   dispatch "index" to stack "today.lc"
   pass dragDrop
end dragDrop

on dragEnter
   set the allowableDragActions to "link"
   set the dragAction to "Link"
   pass dragEnter
end dragEnter

