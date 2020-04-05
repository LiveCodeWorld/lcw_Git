script "Global | GIT | Unmerged paths | Added by them | File | Menu"
--> MetaData
-
license: GPLv3
name: Global | GIT | Unmerged paths | Added by them | File | Menu
type: controller
version: 0.1

/*Here you can describe this menu.
Full help text should be provided on the linked wiki.*/


--> Variables
-
local LocalArray


--> Menu | Init
-
on menu_Init tObject   
   -- do something when the menu first loads
end menu_Init


--> Global | GIT | Unmerged paths | Added by them | File | Menu
-
on menu_AddFileToStage arrayView
   put _getFile (arrayView) into someFile
   git_AddFile someFile
   put the result into addResult
   refresh
end menu_AddFileToStage

on menu_RemoveFileFromStage arrayView
   put _getFile (arrayView) into someFile
   git_RemoveFile someFile
   put the result into removeResult
   refresh
end menu_RemoveFileFromStage


--> Deps
-
