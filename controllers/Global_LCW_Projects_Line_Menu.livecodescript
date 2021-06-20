script "Global | LCW | Projects | Line | Menu"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: Global | LCW | Projects | Line | Menu
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
   -- called first
   pass menu_Target
end menu_Target

getprop menu_CheckTarget [mTarget]
   -- use to do initialisation
   pass menu_CheckTarget
end menu_CheckTarget

on menu_Init tObject
   -- not needed any more
   -- use "menu_CheckTarget" to any initialisation
   put the display_View of tObject into displayView
   --
   put the dispayed_Data of displayView into LocalArray ["dataArray"]
end menu_Init

getprop test_Param [displayView]
  return "b"
end test_Param

getprop test_Params [displayView]
   return "a,b,c"
end test_Params

getprop menu_CheckTarget [displayView]
  return true
end menu_CheckTarget

getprop checked_TestChecked
   return true
end checked_TestChecked

getprop disabled_Test
  return false -- true, "delete"
end disabled_Test


--> Global | LCW | Projects | Line | Menu
-
on menu_Test displayView, abc
   put displayView & CR & abc
end menu_Test

on menu_TestChecked
  put menu_GetChecked (the params)
end menu_TestChecked

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_Experiment displayView
   put displayView
end menu_Experiment


--> Deps
-
