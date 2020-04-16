script "Global | GIT | Changes to be committed | New file | File | Menu"
--> MetaData
-
license: GPLv3
name: Global | GIT | Changes to be committed | New file | File | Menu
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


--> Global | GIT | Changes to be committed | New file | File | Menu
-
on menu_CommitFile arrayView
   put lcw_Ask ("Comment on this change...") into someComment
   put _getFile (arrayView) into someFile
   
   put true into pVerbose -- for more info
   git_CommitFile someFile, someComment, pVerbose
   put the result into shellResult
   
   display_Lines shellResult, "git_CommitFile"
   refresh
end menu_CommitFile

on _
end _

on menu_RevealInFinder arrayView
   put _getFile (arrayView) into someFile
   finder_Reveal someFile
end menu_RevealInFinder


--> Deps
-
