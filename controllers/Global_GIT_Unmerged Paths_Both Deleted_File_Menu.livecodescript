script "Global | GIT | Unmerged Paths | Both Deleted | File | Menu"
--> MetaData
-
license: GPLv3
name: Global | GIT | Unmerged Paths | Both Deleted | File | Menu
type: controller
version: 0.1

/*Here you can describe this menu.
Full help text should be provided on the linked wiki.*/


--> Variables
-
local LocalArray

--> Menu | Init
-


--> Global | GIT | Unmerged Paths | Both Deleted | File | Menu
-
on menu_About
   answer "Both deleted means..."
end menu_About

on menu_AddFileToStage arrayView
   put _getFile (arrayView) into someFile
   git_AddFile someFile
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
