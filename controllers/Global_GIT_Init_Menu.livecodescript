script "Global_GIT_Init_Menu"
--> MetaData
-
license: GPLv3
name: Global_GIT_Init_Menu
type: controller
version: 0.2

/*
This menu is for project displays. Typically an ndex_View with then menu_Target set to the project_Name.

getprop disabled_GitStatus
   if LocalArray ["gitIsActive"] is true then
      return false
   else
      return "delete"
   end if
end disabled_GitStatus
*/


--> Menu | Init
-
/* mTarget should already be set by set the menu_Target of displayView to projectName */

local LocalArray

on menu_Init tObject
   put the view_Object of tObject into displayView
   put "LivecodeWorld" into LocalArray ["orgName"]
   
   put displayView into LocalArray ["displayView"]
   put the title_Text of displayView into projectName
   put the displayed_GitCheckoutFolder of displayView into gitFolder
   put gitFolder into projectFolder
   --
   put git_GetActiveStatus (gitFolder) into gitIsActive
   put git_GetRemoteAddress (projectFolder) into gitRemoteAddress
   --
   put projectName into LocalArray ["projectName"]
   put projectFolder into LocalArray ["projectFolder"] -- should be the same as gitFolder
   put gitIsActive into LocalArray ["gitIsActive"]
   put gitRemoteAddress into LocalArray ["gitRemoteAddress"]
   put gitFolder into LocalArray ["gitFolder"]
   
   put projectName & ".wiki" into wikiProjectName
   put library_FetchProjectFolder (wikiProjectName) into wikiFolder
   if there is a folder wikiFolder then
      put wikiFolder into LocalArray ["wikiFolder"]
   end if
   
   put github_LivecodeWorldProjectExists (projectName) into gitHubRepoExists
   put gitHubRepoExists into LocalArray ["gitHubRepoExists"]
end menu_Init
 
getprop menu_Target [displayObject]
   -- not called in subMenus (so not using)
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

getprop disabled_CreateGithubProject
   if LocalArray ["gitIsActive"] is false then return true
   if LocalArray ["gitHubRepoExists"] is true then
      return true
   else
      return false
   end if
end disabled_CreateGithubProject

getprop disabled_FixRemote
   if LocalArray ["gitHubRepoExists"] is false then return true
   
   put LocalArray ["gitRemoteAddress"] into gitRemoteAddress
   if gitRemoteAddress is empty then
      return false
   else
      return "true"
   end if
end disabled_FixRemote


--> Events
-
on mouseDoubleUp_GitHub indexView, lcwRepoName
   -- put LocalArray ["orgName"] into orgName
   github_Launch lcwRepoName
end mouseDoubleUp_GitHub


--> Global | GIT | Init | Menu
-
on menu_RefreshDisplay 
   put LocalArray ["projectName"] into projectName
   display_GitRefreshProjectName projectName
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
   
   github_CreateProject repoName, gitFolder, repoDescription
   put the result into githubProjectArray
   -- 
   put githubProjectArray ["ssh_url"] into remoteSshUrl
   --
   put remoteSshUrl
end menu_CreateGithubProject

on menu_DisplayGithubProjects
   put LocalArray ["orgName"] into orgName
   --
   display_GithubProjects orgName
end menu_DisplayGithubProjects

on _
end _

on menu_FixRemote
   put LocalArray ["projectName"] into projectName
   put LocalArray ["gitFolder"] into gitFolder
   put LocalArray ["gitRemoteAddress"] into gitRemoteAddress
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

on _
end _

on menu_DisplayGithubInfo
   put LocalArray ["gitRemoteAddress"] into gitRemoteAddress
   --
   put github_FindRepoName (gitRemoteAddress) into repoName
   display_GitHubInfo repoName
end menu_DisplayGithubInfo

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


--> Dev | Props
-
getprop disabled_DisplayRemote
   if LocalArray ["gitIsActive"] is true then
      return false
   else
      return "delete"
   end if
end disabled_DisplayRemote

getprop disabled_DisplayGithubInfo [projectName]
   if LocalArray ["gitHubRepoExists"] then
      return false
   else
      return true
   end if
end disabled_DisplayGithubInfo

getprop disabled_DeleteInvisibleGitFolder
   if LocalArray ["gitIsActive"] is true then
      return false
   else
      return true
   end if
end disabled_DeleteInvisibleGitFolder
