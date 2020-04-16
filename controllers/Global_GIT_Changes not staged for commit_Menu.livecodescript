script "Global | GIT | Changes not staged for commit | Menu"
--> MetaData
-
license: GPLv3
name: Global | GIT | Changes not staged for commit | Menu
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


--> Global | GIT | Changes not staged for commit | Menu
-
on menu_CommitAllStaged arrayView
   put lcw_Ask ("Comment on this change...") into someComment
   put LocalArray ["gitCheckoutFolder"] into gitCheckoutFolder
   
   git_CommitChanges someComment, gitCheckoutFolder
   put the result into shellResult
   
   display_Lines shellResult, "git_CommitChanges"
   refresh
end menu_CommitAllStaged


--> Deps
-
