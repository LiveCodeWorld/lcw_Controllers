script "Global | Controllers | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Controllers | Menu
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

getprop menu_CheckTarget
   return true
end menu_CheckTarget


--> Global | Controllers | Menu
-
on menu_NewController dView
   -- view_Untracked
   put lcw_Ask ("What is the name for the new controller?", "xxx.lc", "LCW Controllers", dView) into shortFile
   --
   transport_Create shortFile
   put the result into sPath
   --
   display_Transporters dView
   edit the script of stack sPath
end menu_NewController

private on _
end _

on menu_MenuEdit displayView
   menu_Edit "Global | Controllers | Menu"
end menu_MenuEdit

on submenu_Dev
   return menu_DevTitle ("Global | Controllers | Menu")
end submenu_Dev
