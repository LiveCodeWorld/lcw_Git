script "Global | GIT | Branch | File | Menu"
--> MetaData
-
license: GPLv3
name: Global | GIT | Branch | File | Menu
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


--> Global | GIT | Branch | File | Menu
-
on menu_TestBranch arrayView
   put LocalArray ["gitCheckoutFolder"] into gitCheckoutFolder
   put "git branch" into someShell
   put git_ExecuteShellCommand (someShell, gitCheckoutFolder) into branchNames
   put branchNames
end menu_TestBranch

on _
end _

on submenu_Branch
   return "Global | GIT | Branch | Menu"
end submenu_Branch


--> Deps
-
