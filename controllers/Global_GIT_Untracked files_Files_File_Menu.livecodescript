script "Global | GIT | Untracked files | Files | File | Menu"
--> MetaData
-
license: GPLv3
name: Global | GIT | Untracked files | Files | File | Menu
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


--> Global | GIT | Untracked files | Files | File | Menu
-
on menu_AddUntrackedFile arrayView
   put _getFile (arrayView) into someFile
   git_AddFile someFile
   refresh
end menu_AddUntrackedFile

on _
end _

on menu_EditScript arrayView
   put _getFile (arrayView) into someFile
   edit the script of stack someFile
end menu_EditScript


--> Deps
-
