script "behavior_ViewControllerDrop" with behavior "thought.lc"
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
   index
end mouseUp


--> Events | Drag
-
on dragDrop
   index
end dragDrop

on dragEnter
   set the allowableDragActions to "link"
   set the dragAction to "Link"
end dragEnter


--> Props
-
getprop drop_ControllerName
   put the drop_Controller of me into dropControllers
   repeat for each line dropController in dropControllers
      put the short name of dropController & CR after dStackNames
   end repeat
   delete char -1 of dStackNames
   return dStackNames
end drop_ControllerName

setprop drop_ControllerName dStackName
   put drop_ControllerPath (dStackName) into sPath
   if sPath is empty then return empty
   --
   put the name of stack "behavior_ViewControllerDrop" into bObjects
   put CR & the name of stack sPath after bObjects
   --
   set the behavior_Objects of me to bObjects
   return the result
end drop_ControllerName

getprop drop_Controller
   put the behavior_Objects of me into bObjects
   get the name of stack "behavior_ViewControllerDrop"
   line_Delete it, bObjects
   return bObjects
end drop_Controller

setprop drop_Controller dStackName
   put drop_ControllerPath (dStackName) into sPath
   set the behavior_AddStack of me to sPath
   return the result
end drop_Controller

function drop_ControllerPath dStackName
   if exists (stack dStackName) then
      return the filename of stack dStackName
   else
      -- assume it is a lcw_Controller and that stackName = short path
      put env_ProjectFolder ("lcw_Controllers", "controllers") into cFolder
      if cFolder is empty then
         return empty
      else
         put cFolder & dStackName into stackPath
         if there is a stack stackPath then
            return stackPath
         else
            return empty
         end if
      end if 
   end if
end drop_ControllerPath


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
