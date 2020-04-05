script "Global_GIT_Init_Menu"
--> MetaData
-
license: GPLv3
name: Global_GIT_Init_Menu
type: controller
version: 0.2

/*
This menu is for project displays. Typically an ndex_View with then menu_Target set to the project_Name.
*/


--> Menu | Props
-
/* mTarget should already be set by set the menu_Target of displayView to projectName */

local LocalArray

on menu_Init tObject
   put the view_Object of tObject into displayView
   put "LivecodeWorld" into LocalArray ["orgName"]
   
   put displayView into LocalArray ["displayView"]
   put the title_Text of displayView into projectName
   put the displayed_GitCheckoutFolder of displayView into gitCheckoutFolder
   put gitCheckoutFolder into projectFolder
   --
   put git_GetActiveStatus (gitFolder) into someBoolean
   put git_GetRemoteAddress (projectFolder) into remoteAddress
   --
   /*
   put the project_Folder of stack projectName into projectFolder
   put the git_CheckoutFolder of stack projectName into gitFolder
   -- put project_FolderFromName (projectName) into projectFolder
   -- put project_GetFolder (projectName) into gitRootFolder
   */
   --
   put projectName into LocalArray ["projectName"]
   put projectFolder into LocalArray ["projectFolder"] -- should be the same as gitFolder
   put gitIsActive into LocalArray ["gitIsActive"]
   put remoteAddress into LocalArray ["remoteAddress"]
   put gitFolder into LocalArray ["gitFolder"]
   
   put projectName & ".wiki" into wikiProjectName
   put library_FetchProjectFolder (wikiProjectName) into wikiFolder
   if there is a folder wikiFolder then
      put wikiFolder into LocalArray ["wikiFolder"]
   end if
   
   put github_ListOrgRepos() into lcwRepoNames
   put lcwRepoNames into LocalArray ["lcwRepoNames"]
   put projectName is among the lines of LocalArray ["lcwRepoNames"] into gitHubRepoExists
   put gitHubRepoExists into LocalArray ["gitHubRepoExists"]
end menu_Init

getprop menu_Target [displayObject]
   -- not called in subMenus ()so not using)
   put LocalArray ["projectName"] into projectName
   return projectName
end menu_Target

getprop disabled_InitialiseGit
   if LocalArray ["gitIsActive"] is true then
      return "delete"
   else
      return false
   end if
end disabled_InitialiseGit

getprop disabled_GitStatus
   if LocalArray ["gitIsActive"] is true then
      return false
   else
      return "delete"
   end if
end disabled_GitStatus

getprop disabled_DisplayRemote
   if LocalArray ["gitIsActive"] is true then
      return false
   else
      return "delete"
   end if
end disabled_DisplayRemote

getprop disabled_FixRemote
   put _gitRemoteAddress() into gitRemoteAddress
   if gitRemoteAddress is empty then
      return false
   else
      return "true"
   end if
end disabled_FixRemote

getprop disabled_DeleteInvisibleGitFolder
   if LocalArray ["gitIsActive"] is true then
      return false
   else
      return true
   end if
end disabled_DeleteInvisibleGitFolder

getprop disabled_CreateGithubProject
   if LocalArray ["gitIsActive"] is false then return true
   if LocalArray ["gitHubRepoExists"] then
      return true
   else
      return false
   end if
end disabled_CreateGithubProject

getprop disabled_LaunchGithub [projectName]
   if LocalArray ["gitHubRepoExists"] then
      return false
   else
      return true
   end if
end disabled_LaunchGithub

getprop disabled_DisplayGithubInfo [projectName]
   if LocalArray ["gitHubRepoExists"] then
      return false
   else
      return true
   end if
end disabled_DisplayGithubInfo

getprop disabled_AddProjectWiki [projectName]
   if LocalArray ["gitHubRepoExists"] is false then return "true"
   
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


--> Events
-
on mouseDoubleUp_GitHub indexView, lcwRepoName
   put LocalArray ["orgName"] into orgName
   github_Launch lcwRepoName
end mouseDoubleUp_GitHub


--> Global | GIT | Init | Menu
-
on menu_RefreshDisplay 
   put LocalArray ["projectName"] into projectName
   display_GitRefresh projectName
end menu_RefreshDisplay

on _
end _

on menu_InitialiseGit
   put LocalArray ["projectName"] into projectName
   put LocalArray ["displayView"] into displayView
   put LocalArray ["projectFolder"] into projectFolder
   --
   put merge ("Are you sure you want to initialise the project '[[projectName]]' with a git repo?") into someQuestion
   dispatch "lcw_AnswerSheet" to displayView with someQuestion
   --
   git_InitFolder projectFolder
   put the result into testGitRootFolder
   --
   if testGitRootFolder is not projectFolder then
      breakpoint
   end if
end menu_InitialiseGit

on menu_FixRemote
   put LocalArray ["projectName"] into projectName
   put LocalArray ["gitFolder"] into gitFolder
   --
   put _GitRemoteAddress() into oldRemoteAddress
   --
   put merge ("git@github.com:LiveCodeWorld/[[projectName]].git") into newRemoteAddress
   put lcw_Ask ("Enter git remote address...", newRemoteAddress)into gitRemoteAddress
   --
   -- git_SetRemoteOrigin gitRemoteAddress, gitFolder
   git_AddFolderToRemote gitFolder, gitRemoteAddress
   put the result into shellResult
   --
   put shellResult
   --
   return shellResult
end menu_FixRemote

on _
end _

on menu_CreateGithubProject
   put LocalArray ["projectName"] into projectName   -- "lcw_Git"
   put LocalArray ["lcwRepoNames"] into lcwRepoNames
   put LocalArray ["gitFolder"] into gitFolder
   
   -- let's check to see if GitHub repo exists (Should be disabled)
   if projectName is among the lines of lcwRepoNames then
      answer warning "LiveCodeWorld repository already exists!"
      exit to top
   end if
   
   -- check to see if remote address already exists
   put git_GetRemoteAddress (gitFolder) into oldRemoteAddress
   if oldRemoteAddress begins with "git@github.com:LiveCodeWorld/" then
      -- not sure what to do???
      put oldRemoteAddress
      answer warning "LiveCodeWorld repository is already linked but remote repo does not exist! Unlink it first?"
      exit to top
   end if
   
   -- let's create it
   put lcw_Ask ("Give the new repo a name..", projectName) into repoName
   put lcw_Ask ("Give repo a description...", "A project to interact with git and Github.") into repoDescription
   
   breakpoint
   github_CreateProject repoName, gitFolder, repoDescription
   put the result into githubProjectArray
   -- 
   put githubProjectArray ["ssh_url"] into remoteSshUrl
   return remoteSshUrl
end menu_CreateGithubProject

on menu_DisplayGithubProjects
   put LocalArray ["orgName"] into orgName
   --
   put github_ListOrgRepos (orgName) into lcwRepoNames
   --
   display_Lines lcwRepoNames, orgName, "mouseDoubleUp_GitHub", "Github Repos", pPalette
   put the result into displayView
   set the title_Menu of displayView to "Global | Github | Menu"
end menu_DisplayGithubProjects


on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_DisplayRemote
   put LocalArray ["gitFolder"] into gitFolder
   --
   put git_GetRemoteAddress (gitFolder)
end menu_DisplayRemote

on menu_DisplayGithubInfo
   put LocalArray ["remoteAddress"] into remoteAddress
   --
   put github_FindRepoName (remoteAddress) into repoName
   display_GitHubInfo repoName
end menu_DisplayGithubInfo

on _
end _

on menu_DeleteInvisibleGitFolder arrayView
   put LocalArray ["gitFolder"] into gitFolder
   --
   set the itemdelimiter to slash
   put item -1 of gitFolder into projectName
   put merge ("Are you sure you want to remove the local git repository and all it's history of file changes from the local project '[[projectName]]'?") into someQuestion
   dispatch "lcw_AnswerSheet" to arrayView with someQuestion
   
   breakpoint -- be careful!
   git_DeleteInvisibleRepoFolder gitFolder
end menu_DeleteInvisibleGitFolder


--> Private
-
private function _gitRemoteAddress
   put LocalArray ["gitFolder"] into gitFolder
   put git_GetRemoteAddress (gitFolder) into oldRemoteAddress
   return oldRemoteAddress
end _gitRemoteAddress
