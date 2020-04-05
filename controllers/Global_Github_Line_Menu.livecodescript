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

getprop disabled_DisplayGitStatus [displayView]
   put the selected_Line of displayView into repoName
   if exists (stack repoName) then
      return false
   else
      return true
   end if
end disabled_DisplayGitStatus


--> Global | Github | Line | Menu
-
on menu_LaunchGithub displayView
   put the selected_Line of displayView into repoName
   --
   github_Launch repoName
end menu_LaunchGithub

on _
end _

on menu_DisplayGitStatus displayView
   put the selected_Line of displayView into repoName
   put the name of stack repoName into sObject
   --
   display_GitStatus sObject
end menu_DisplayGitStatus

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_DisplayGithubRepoArray displayView
   put the selected_Line of displayView into repoName
   --
   put github_FetchRepoArray (repoName) into repoArray
   --
   display_Array repoArray, repoName
end menu_DisplayGithubRepoArray
