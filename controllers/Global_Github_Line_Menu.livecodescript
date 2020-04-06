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

getprop disabled_DisplayGitStatus [lineView]
   put the selected_Line of lineView into repoName
   if exists (stack repoName) then
      return false
   else
      return true
   end if
end disabled_DisplayGitStatus

getprop disabled_DisplayProjectView [lineView]
   put the selected_Line of lineView into repoName
   --
   put display_FindView ("Model and Libraries", repoName) into displayView
   if exists (displayView) then
      return false
   else
      return true
   end if
end disabled_DisplayProjectView


--> Global | Github | Line | Menu
-
on menu_LaunchGithub lineView
   put the selected_Line of lineView into repoName
   --
   github_Launch repoName
end menu_LaunchGithub

on _
end _

on menu_DisplayProjectView lineView
   put the selected_Line of lineView into repoName
   --
   put display_FindView ("Model and Libraries", repoName) into displayView
   --
   object_GoTo displayView
end menu_DisplayProjectView
   
on menu_DisplayGitStatus lineView
   put the selected_Line of lineView into repoName
   --
   put the name of stack repoName into sObject
   --
   display_GitStatus sObject
end menu_DisplayGitStatus

on _
end _

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
