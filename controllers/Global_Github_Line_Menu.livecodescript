script "Global | Github | Line | Menu"
--> MetaData
-
license: GPLv3
name: Global | Github | Line | Menu
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

-- getprop disabled_LaunchGithub [projectName]
if LocalArray ["gitHubRepoExists"] then
   return false
else
   return true
end if
end disabled_LaunchGithub


--> Global | Github | Line | Menu
-
on menu_LaunchGithub displayView
   put the selected_Line of displayView into lcwRepo
   --
   github_Launch lcwRepo
end menu_LaunchGithub


--> Deps
-
