script "Global_Github_Menu"
--> MetaData
-
license: GPLv3
name: Global_Github_Menu
type: controller
version: 0.1


--> Menu | Init
-
/* mTarget should already be set by set the menu_Target of displayView to projectName */

local LocalArray

on menu_Init tObject
   put the view_Object of tObject into displayView
   put "LivecodeWorld" into LocalArray ["orgName"]
   
   put displayView into LocalArray ["displayView"]
   put the title_Text of displayView into githubTeamName
end menu_Init

command stuff
   --
   put projectName into LocalArray ["projectName"]
   put projectName & ".wiki" into wikiProjectName
   put library_FetchProjectFolder (wikiProjectName) into wikiFolder
   if there is a folder wikiFolder then
      put wikiFolder into LocalArray ["wikiFolder"]
   end if
   
   put github_LivecodeWorldProjectExists (projectName) into gitHubRepoExists
   put gitHubRepoExists into LocalArray ["gitHubRepoExists"]
end stuff


--> Global | Github | Menu
-
on menu_LaunchGithub
   github_Launch
end menu_LaunchGithub

on _
end _

on subMenu_Dev
   return "Dev | Menu"
end subMenu_Dev


--> Dev | Menu
-
on menu_DisplayGithubRepoArray
   put LocalArray ["projectName"] into repoName
   put github_FetchRepoArray (repoName) into repoArray
   --
   display_Array repoArray, repoName
end menu_DisplayGithubRepoArray

on menu_DisplayGithubOrgArray
   put github_FetchOrgRepoAray() into reposArray
   --
   display_Array reposArray, "github_FetchOrgRepoAray()"
end menu_DisplayGithubOrgArray

on _
end _

on menu_AddProjectWiki projectName
   breakpoint -- not finished
   
   put projectName & ".wiki" into wikiProjectName
   
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

on menu_CreateGithubProjectPages projectName
   lcw_Answer "Add new wiki pages for each project stackto the local github project"
   --
   put LocalArray ["wikiFolder"] into wikiFolder
   put LocalArray ["displayView"] into displayView
   put the view_Index of displayView into stackNames
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


--> Dev | Props
-
getprop disabled_CreateGithubProjectPages [projectName]
   put LocalArray ["wikiFolder"] into wikiFolder
   if there is a folder wikiFolder then
      return false
   else
      return true
   end if
end disabled_CreateGithubProjectPages

getprop disabled_AddProjectWiki [projectName]
   if LocalArray ["gitHubRepoExists"] is false then return "true"
   
   put LocalArray ["wikiFolder"] into wikiFolder
   if there is a folder wikiFolder then
      return "delete"
   else
      return false
   end if
end disabled_AddProjectWiki
