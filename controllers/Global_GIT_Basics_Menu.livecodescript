﻿script "Global | GIT | Basics | Menu"
--> MetaData
-
license: GPLv3
name: Global | GIT | Basics | Menu
type: controller
version: 0.3

/*
private function _CheckProjectName displayView
   -- check LCW project
   put the title_Text of displayView into projectName
   if there is a stack projectName then
      put projectName into LocalArray ["projectName"]
      return projectName
   else
      put empty into LocalArray ["projectName"]
      return empty
   end if
end _CheckProjectName

private command _LoadGitDisplayView projectName
   put display_FindView ("Git Status", projectName) into gitDisplayView
   put gitDisplayView into LocalArray ["gitDisplayView"]
   return gitDisplayView
end _LoadGitDisplayView
*/


--> Where?
-
private function _FilesToCommit
   put LocalArray ["statusArray"] into statusArray
   put statusArray ["Changes not staged for commit:"]["modified"] into modifiedFiles
   return modifiedFiles
end _FilesToCommit

private function _IsGitStatusDisplay
   put LocalArray ["displayView"] into displayView
   put LocalArray ["projectName"] into projectName
   return _ExistsGitStatusDisplay (projectName)
end _IsGitStatusDisplay


--> Menu | Props
-
local LocalArray

getprop menu_Target [tObject]
   put the display_View of tObject into gitDisplayView
   if gitDisplayView is empty then return tObject
   put gitDisplayView into LocalArray ["gitDisplayView"]
   --
   put the title_Text of gitDisplayView into projectName
   put projectName into LocalArray ["projectName"]
   -- _LoadGitDisplayView projectName
   
   put env_ConstructProjectFolder (projectName) into projectFolder    
   put git_GetActiveStatus (projectFolder) into gitIsActive
   if gitIsActive is true then
      put projectFolder into gitFolder
   else
      put empty into gitFolder
   end if
   put gitFolder into LocalArray ["gitFolder"]
   put gitIsActive into LocalArray ["gitIsActive"]
   put _RemoteIsBad() into LocalArray ["_RemoteIsBad"]
   
   put git_GetRemoteAddress (gitFolder) into remoteAddress
   put github_ListOrgRepos() into LocalArray ["lcwRepoNames"]
   put remoteAddress into LocalArray ["remoteAddress"]
   
   put _GetStatusArray() into statusArray
   put statusArray into LocalArray ["statusArray"]
   --
   return projectFolder
end menu_Target

getprop gitDocumentation_Params
   return the hkey_CaseConditions ["M menu_GitDocumentation"] of me
end gitDocumentation_Params

getprop disabled_PushCurrentBranch
   put LocalArray ["statusArray"] into statusArray
   put statusArray ["Branch"] into branchArray
   put "(use 'git push' to publish your local commits)" into pushLine
   replace "'" with quote in pushLine
   put the keys of branchArray into branchKeys
   if pushLine is among the lines of branchKeys then
      return false
   else
      return true
   end if
end disabled_PushCurrentBranch

getprop disabled_RefreshGitStatus
   if LocalArray ["gitIsActive"] is false then
      return true
   end if
   
   put LocalArray ["projectName"] into projectName
   if _ExistsGitStatusDisplay (projectName) then
      return false
   else
      return "delete"
   end if
end disabled_RefreshGitStatus

getprop disabled_DisplayGitStatus
   if LocalArray ["gitIsActive"] is false then
      return true
   end if
   
   put LocalArray ["projectName"] into projectName
   if _ExistsGitStatusDisplay (projectName) then
      return "delete"
   else
      return false
   end if
end disabled_DisplayGitStatus

getprop disabled_Pull
   return LocalArray ["_RemoteIsBad"]
end disabled_Pull

getprop disabled_PushCurrentBranch
   return LocalArray ["_RemoteIsBad"]
end disabled_PushCurrentBranch

getprop disabled_AddAllUntracked
   if LocalArray ["gitIsActive"] is false then return true
   put _FilesToAdd() into untrackedFiles
   if untrackedFiles is empty then
      return true
   else
      return false
   end if
end disabled_AddAllUntracked

getprop disabled_StageThenCommit
   if LocalArray ["gitIsActive"] is false then return true
   if _FilesToAdd() is not empty then return true
   
   if _FilesToStageAndCommit() then
      return false
   else
      return true
   end if
end disabled_StageThenCommit


--> Global | GIT | Basics | Menu
-
on menu_DisplayGitStatus
   put LocalArray ["gitFolder"] into gitFolder
   --
   stack_SaveEdited "all"
   display_GitFolderStatus gitFolder
end menu_DisplayGitStatus

on menu_SaveAndRefresh
   stack_SaveEdited "all"
   _RefreshGitStatus
end menu_SaveAndRefresh

on menu_Pull gitFolder
   put LocalArray ["gitFolder"] into gitFolder
   
   -- TO PULL A new BRANCH FROM A REMOTE REPOSITORY
   -- put merge("git pull origin [[remoteBranch]]:[[newLocalBranch]]") into someShell
   -- put "git pull" into someShell
   -- put "git pull origin master" into someShell
   
   put git_CurrentBranchName (gitFolder) into currentBranchName
   put "git pull origin" && kwote (currentBranchName) into someShell
   
   put git_ExecuteShellCommand (someShell, gitFolder) into shellResult
   display_Lines shellResult, someShell
   put the result into indexView
   set the title_Menu of indexView to "Global | Git | Pull | Menu"
   set the line_Menu of indexView to "Global | Git | Pull | Line | Menu"
   -- set the displayed_ScriptObject of indexView to empty
   set the displayed_GitCheckoutFolder of indexView to gitFolder
   set the displayed_GitBranch of indexView to currentBranchName
   
   _RefreshGitStatus
   
   /*
   stack_RevertLoaded
   put the result into displayView
   set the menu_Title of displayView to "Global | Git | Pull | Menu"
   */
end menu_Pull

on _
end _

on menu_AddAllUntracked gitFolder
   /*
   -- dig into this. "git add --update" does not seem to do anything useful.
   git_AddChanged
   */
   set the cursor to watch
   put LocalArray ["gitFolder"] into gitFolder
   
   git_AddEverything gitFolder
   put the result into shellResult
   if shellResult is not empty then
      lcw_Notify shellResult
   end if
   _RefreshGitStatus
end menu_AddAllUntracked

on menu_StageThenCommit projectFolder
   put LocalArray ["gitFolder"] into gitFolder
   --
   put lcw_Ask ("Comment on this change...") into someComment
   git_CommitChanges someComment, gitFolder
   _RefreshGitStatus
end menu_StageThenCommit

on _
end _

on menu_PushCurrentBranch projectFolder
   -- TO push THE new BRANCH TO A REMOTE REPOSITORY
   set the cursor to watch
   put LocalArray ["gitFolder"] into gitFolder
   --
   display_GitPushCurrentBranch gitFolder
end menu_PushCurrentBranch

on _
end _

on menu_LaunchGithubProject projectFolder
   put LocalArray ["projectName"] into projectName
   --
   put the github_LaunchURL of stack projectName into someURL
   launch url someURL
end menu_LaunchGithubProject

on menu_GitDocumentation projectFolder, menuChoice
   switch menuChoice
      case "Crash course"
         launch url "http://git.or.cz/course/svn.html"
         break
      case "Git Wiki"
         launch url "http://git.or.cz/gitwiki/GitDocumentation"
         break
      case "Git User manual"
         launch url "http://www.kernel.org/pub/software/scm/git/docs/user-manual.html"
         break
   end switch
end menu_GitDocumentation


--> Private
-
private function _FilesToStageAndCommit
   put LocalArray ["statusArray"] into statusArray
   put statusArray ["Changes not staged for commit:"] into notStagedArray
   put statusArray ["Changes to be committed:"] into toCommitArray
   switch
      case notStagedArray is not empty
      case toCommitArray is not empty
         return true
      default
         return false
   end switch
end _FilesToStageAndCommit

private function _FilesToAdd
   put LocalArray ["statusArray"] into statusArray
   put statusArray ["Untracked files:"]["files"] into untrackedFileList
   return untrackedFileList
end _FilesToAdd

private function _ExistsGitStatusDisplay projectName
   -- put display_FindView ("Git Status", projectName) into gitDisplayView
   put LocalArray ["gitDisplayView"] into gitDisplayView
   return exists (gitDisplayView)
end _ExistsGitStatusDisplay

private function _GetStatusArray
   put LocalArray ["gitDisplayView"] into gitDisplayView
   if exists (gitDisplayView) is false then
      -- slow
      put LocalArray ["gitFolder"] into gitFolder
      put git_GetStatusArray (gitFolder) into statusArray
   else
      put the displayed_Array of gitDisplayView into statusArray
   end if
   return statusArray
end _GetStatusArray

private command _RefreshGitStatus
   put LocalArray ["projectName"] into projectName
   display_GitRefreshProjectName projectName
end _RefreshGitStatus

private function _RemoteIsBad
   put LocalArray ["gitFolder"] into gitFolder
   put git_GetRemoteAddress (gitFolder) into remoteAddress
   
   switch
      case there is not a folder gitFolder
         return true
      case remoteAddress begins with "git@github.com:LiveCodeWorld/"
         return false
      default
         -- remote address is not a LiveCodeWorld project
         -- disabling for safety (this is not a generic git tool)
         return true
   end switch
end _RemoteIsBad
