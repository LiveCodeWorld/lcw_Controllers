script "Global | Controller | Drop | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Controller | Drop | Menu
type: controller
version: 0.1

/*Here you can describe this menu.
Full help text should be provided on the linked wiki.*/


--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target [tObject]
   -- return display_MenuTarget(tObject)
   return the display_View of tObject
end menu_Target

getprop menu_CheckTarget [cameraView]
   return exists (cameraView)
end menu_CheckTarget

getprop dropController_Param [displayView]
   put the drop_ControllerName of displayView into dName
   return dName
end dropController_Param

getprop dropController_Params
   get project_ListStackNames ("stacks", "lcw_Controllers", false)
   sort it
   return it
end dropController_Params


--> Global | Controller | Drop | Menu
-
on menu_DropController displayView, dName
   switch dName
      case "Ask"
         put the drop_ControllerName of displayView into dName
         if dName is empty then put "roster.lc" into dName
         put lcw_Ask ("Choose a controller...", dName, "LCW Controller", displayView) into dName
         break
   end switch
   --
   set the drop_ControllerName of displayView to dName
end menu_DropController

private on _
end _

on menu_EditDropController dropView
   put the drop_Controller of dropView into bObject
   if exists (bObject) is true then
      edit the script of bObject
   else
      breakpoint
      put the behavior of dropView into bObject
      edit the script of bObject
   end if
end menu_EditDropController

private on __
end __

on submenu_Dev
   return menu_DevTitle ("Global | Controller | Drop | Menu")
end submenu_Dev
