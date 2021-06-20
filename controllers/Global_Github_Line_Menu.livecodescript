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
getprop menu_Target [tObject]
   put the selected_Line of tObject into repoProjectName
   return repoProjectName
end menu_Target

getprop disabled_CreateGithubProjectPages [repoProjectName]
   put LocalArray ["wikiFolder"] into wikiFolder
   if there is a folder wikiFolder then
      return false
   else
      return true
   end if
end disabled_CreateGithubProjectPages

getprop disabled_AddProjectWiki [repoProjectName]
   if LocalArray ["gitHubRepoExists"] is false then return "true"
   
   put LocalArray ["wikiFolder"] into wikiFolder
   if there is a folder wikiFolder then
      return "delete"
   else
      return false
   end if
end disabled_AddProjectWiki

getprop disabled_DisplayGitStatus [repoProjectName]
   if exists (stack repoProjectName) then
      return false
   else
      return true
   end if
end disabled_DisplayGitStatus

getprop disabled_DisplayProjectView [repoProjectName]
   put display_FindView ("Model and Libraries", repoProjectName) into displayView
   if exists (displayView) then
      return false
   else
      return true
   end if
end disabled_DisplayProjectView


--> Global | Github | Line | Menu
-
on menu_LaunchGithubProject projectName
   github_Launch projectName
end menu_LaunchGithubProject

on menu_GoGithub projectName
   go_GitHub projectName
end menu_GoGithub

on _
end _

on menu_AddProjectWiki repoProjectName
   breakpoint -- not finished
   
   put repoProjectName & ".wiki" into wikiProjectName
   
   answer folder "Select a folder containing a project..."
   put it into projectFolder
   if it is empty then exit to top
   if projectFolder ends with ".wiki" is false then
      answer warning "Not a GitHub wiki project"
      exit to top
   end if
   
   put projectFolder into projectArray ["projectFolder"]
   put "wiki" into projectArray ["projectType"]
   library_StoreProjectArray wikiProjectName, projectArray
   
   display_LcwProjectList
end menu_AddProjectWiki

on menu_CreateGithubProjectPages repoProjectName
   lcw_Answer "Add new wiki pages for each project stackto the local github project"
   --
   put LocalArray ["wikiFolder"] into wikiFolder
   put LocalArray ["displayView"] into displayView
   put the view_Index of displayView into stackNames
   --
   repeat for each line stackName in stackNames
      put wikiFolder & stackName & ".md" into wikiPageFile
      if there is a file wikiPageFile then
         breakpoint
      else
         put the github_WikiPage of stack stackName into wikiMarkdown
         put "file:" & wikiPageFile into someURL
         put wikiMarkdown into url someURL
      end if
   end repeat
end menu_CreateGithubProjectPages

on _
end _

on menu_DisplayGitStatus repoProjectName
   put the name of stack repoProjectName into sObject
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
on menu_FindProjectView repoProjectName
   put display_FindView ("Model and Libraries", repoProjectName) into displayView
   --
   object_GoTo displayView
end menu_FindProjectView

on menu_DisplayGithubRepoArray repoProjectName
   put github_FetchRepoArray (repoProjectName) into repoArray
   --
   display_View repoArray, repoProjectName
end menu_DisplayGithubRepoArray

