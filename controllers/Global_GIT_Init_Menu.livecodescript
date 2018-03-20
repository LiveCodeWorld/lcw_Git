script "Global_GIT_Init_Menu"
--> MetaData
-
license: GPLv3
name: Global_GIT_Init_Menu
type: controller
version: 0.1

/*
This menu is for project displays. Typically an ndex_View with then menu_Target set to the project_Name.
*/


--> Menu | Props
-
/* mTarget should already be set by set the menu_Target of indexView to projectName */

local LocalArray

on menu_Init tObject
   put the index_View of tObject into indexView
   put indexView into LocalArray ["indexView"]
   put the title_Text of indexView into projectName
   put project_FolderFromName (projectName) into projectFolder
   
   if there is a stack projectName then
      put the git_CheckoutFolder of stack projectName into gitFolder
      -- put there is a folder gitCheckoutFolder into gitIsActive
      put the git_IsActive of stack projectName into gitIsActive
      put gitIsActive into LocalArray ["gitIsActive"]
      put git_GetRemoteAddress (projectFolder) into remoteAddress
   end if
   
   put projectName into LocalArray ["projectName"]
   put projectFolder into LocalArray ["projectFolder"] -- should be the same as gitFolder
   put remoteAddress into LocalArray ["remoteAddress"]
   put gitFolder into LocalArray ["gitFolder"]
   
   put projectName & ".wiki" into wikiProjectName
   put library_FetchProjectFolder (wikiProjectName) into wikiFolder
   if there is a folder wikiFolder then
      put wikiFolder into LocalArray ["wikiFolder"]
   end if
end menu_Init

-- getprop menu_CheckTarget [projectName]
return true
end menu_CheckTarget


--> Global | GIT | Init | Menu
-
on menu_InitialiseGit projectName
   put project_FolderFromName (projectName) into projectFolder
   -- put project_GetFolder (projectName) into gitRootFolder
   --
   git_InitFolder projectFolder
   put the result into testGitRootFolder
   --
   if testGitRootFolder is not projectFolder then
      breakpoint
   end if
end menu_InitialiseGit

on menu_GitStatus projectName
   display_GitProjectStatus projectName
end menu_GitStatus

on _
end _

on menu_TestReadme
   put fedwiki_GitHubReadmePageJson ("lcw_Menus") into readmeJSON
   --
   display_FedwikiPageJson readmeJSON
end menu_TestReadme

on menu_CreateGithubProject
   put LocalArray ["lcwRepoNames"] into lcwRepoNames
   put LocalArray ["shortFolder"] into repoName   -- "lcw_Git"
   put LocalArray ["gitFolder"] into gitFolder
   --
   if repoName is among the lines of lcwRepoNames then
      answer warning "LiveCodeWorld repository already exists!"
      exit to top
   end if
   put git_GetRemoteAddress (gitFolder) into oldRemoteAddress
   if oldRemoteAddress begins with "git@github.com:LiveCodeWorld/" then
      put oldRemoteAddress
      answer warning "LiveCodeWorld repository is already linked but remote repo does not exist!"
      exit to top
   end if
   --
   put lcw_Ask ("Give the new repo a name..", repoName) into repoName
   put lcw_Ask ("Give repo a description...", "A project to interact with git and Github.") into repoDescription
   --
   github_CreateProject repoName, gitFolder, repoDescription
   --
   refreshGitStatus
   if addResult is not empty then
      beep
      put addResult
   end if
end menu_CreateGithubProject

on menu_LaunchGithub displayView, lcwRepo
   -- put LocalArray ["shortFolder"] into lcwRepo -- lazy
   github_Launch lcwRepo
end menu_LaunchGithub

-- on menu_LaunchGithub
put LocalArray ["remoteAddress"] into remoteAddress
put github_FindRepoName (remoteAddress) into repoName
github_Launch repoName
end menu_LaunchGithub

on menu_DisplayGithubInfo
   put LocalArray ["remoteAddress"] into remoteAddress
   put github_FindRepoName (remoteAddress) into repoName
   display_GitHubInfo repoName
end menu_DisplayGithubInfo

on _
end _

on menu_AddProjectWiki projectName
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

on menu_CreateLibraryPages projectName
   -- put projectName & ".wiki" into wikiProjectName
   -- put library_FetchProjectFolder (wikiProjectName) into wikiFolder
   put LocalArray ["wikiFolder"] into wikiFolder
   put LocalArray ["indexView"] into indexView
   put the view_Index of indexView into stackNames
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
end menu_CreateLibraryPages

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev



--> Global | GIT | Init | Menu | Props
-
getprop lcw_Repo
   put LocalArray ["shortFolder"] into repoName -- lazy
   return repoName
end lcw_Repo

getprop lcw_Repos
   put LocalArray ["lcwRepoNames"] into lcwRepoNames
   sort lcwRepoNames
   return lcwRepoNames
end lcw_Repos


--> Global | GIT | Init | Menu | Disabled
-
getprop disabled_CreateGithubProject [projectName]
   put LocalArray ["shortFolder"] into repoName -- lazy
   put LocalArray ["lcwRepoNames"] into lcwRepoNames
   if repoName is among the lines of lcwRepoNames then
      return true
   else
      return false
   end if
end disabled_CreateGithubProject

getprop disabled_InitialiseGit [projectName]
   put LocalArray ["gitIsActive"] into gitIsActive
   if gitIsActive is true then
      return "delete"
   else
      return false
   end if
end disabled_InitialiseGit

getprop disabled_GitStatus [projectName]
   put LocalArray ["gitIsActive"] into gitIsActive
   if gitIsActive is true then
      return false
   else
      return "delete"
   end if
end disabled_GitStatus

getprop disabled_AddProjectWiki [projectName]
   -- put projectName & ".wiki" into wikiProjectName
   -- put library_FetchProjectFolder (wikiProjectName) into wikiFolder
   put LocalArray ["wikiFolder"] into wikiFolder
   if there is a folder wikiFolder then
      return "delete"
   else
      return false
   end if
end disabled_AddProjectWiki

getprop disabled_CreateLibraryPages [projectName]
   put LocalArray ["wikiFolder"] into wikiFolder
   if there is a folder wikiFolder then
      return false
   else
      return true
   end if
end disabled_CreateLibraryPages


--> Dev | Menu
-
on menu_DisplayRemote
   breakpoint
   put LocalArray ["gitFolder"] into gitFolder
   put git_GetRemoteAddress (gitFolder)
end menu_DisplayRemote

on menu_FixRemote projectName
   breakpoint
   put LocalArray ["gitFolder"] into gitFolder
   put merge ("git@github.com:LiveCodeWorld/[[projectName]].git") into newRemoteAddress
   put git_GetRemoteAddress (gitFolder) into oldRemoteAddress
   --
   put newRemoteAddress
   put lcw_Ask ("Enter git remote address...", oldRemoteAddress)into gitRemoteAddress
   --
   git_SetRemoteOrigin gitRemoteAddress, projectFolder
   put the result
end menu_FixRemote
