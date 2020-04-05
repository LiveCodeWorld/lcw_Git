script "Global | GIT | Unmerged Paths | Added By Us | File | Menu"
--> MetaData
-
license: GPLv3
name: Global | GIT | Unmerged Paths | Added By Us | File | Menu
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


--> Global | GIT | Unmerged Paths | Added By Us | File | Menu
-
on menu_CheckoutOurs arrayView
   set the cursor to watch
   put "git checkout --ours {shortFile}" into shellTemplate
   put _getFile (arrayView) into someFile
   git_ExecuteMergedShell shellTemplate, someFile
   refresh
end menu_CheckoutOurs

on menu_CheckoutTheirs arrayView
   put "git checkout --theirs {shortFile}" into shellTemplate
   put _getFile (arrayView) into someFile
   git_ExecuteMergedShell shellTemplate, someFile
   refresh
end menu_CheckoutTheirs

on _
end _

on menu_AddFileToStage arrayView
   put _getFile (arrayView) into someFile
   git_AddFile someFile
   put the result into addResult
   refresh
end menu_AddFileToStage

on menu_RemoveFileFromStage arrayView
   put the selected_Value of arrayView into relativeFile
   put relativeFile
end menu_RemoveFileFromStage


--> Deps
-
