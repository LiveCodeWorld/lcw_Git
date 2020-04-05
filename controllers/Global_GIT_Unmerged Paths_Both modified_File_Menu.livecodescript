script "Global | GIT | Unmerged Paths | Both modified | File | Menu"
--> MetaData
-
license: GPLv3
name: Global | GIT | Unmerged Paths | Both modified | File | Menu
type: controller
version: 0.1

/*
Here you can describe this menu.
Full help text should be provided on the linked wiki.
*/


--> Variables
-
local LocalArray


--> Menu | Init
-
on menu_Init tObject   
   -- do something when the menu first loads
end menu_Init


--> Global | GIT | Unmerged Paths | Both modified | File | Menu
-
on menu_AddOursToStage arrayView
   put _getFile (arrayView) into someFile
   
   git_AddFile someFile
   put the result into gitResult
   
   -- git_CheckoutOurs someFile
   --  put the result into gitResult
   
   if gitResult is not empty then display_Lines gitResult, shellTemplate
   refresh
end menu_AddOursToStage

on menu_CheckoutOurs arrayView
   put _getFile (arrayView) into someFile
   git_CheckoutOurs someFile
   put the result into gitResult
   
   if gitResult is not empty then display_Lines gitResult, shellTemplate
   refresh
end menu_CheckoutOurs

on menu_CheckoutTheirs arrayView
   put _getFile (arrayView) into someFile
   
   git_CheckoutTheirs someFile
   put the result into mergeResult
   display_Lines mergeResult, shellTemplate
   refresh
end menu_CheckoutTheirs

on _
end _

on menu_GoToTheirStack
   
end menu_GoToTheirStack


--> Deps
-
