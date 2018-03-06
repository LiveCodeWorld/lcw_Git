script "Global_GIT_Status_Menu"
--> MetaData
-
license: GPLv3
name: Global_GIT_Status_Menu
type: controllers
version: 0.1

--> Variables
-
local LocalArray


--> Menu | Props
-
on menu_Init tObject
   put the display_View of tObject into displayView
   put displayView into LocalArray ["displayView"]
   put the title_Text of displayView into LocalArray ["shortFolder"]
   put the displayed_ScriptObject of displayView into LocalArray ["scriptObject"]
   put the displayed_GitCheckoutFolder of displayView into LocalArray ["gitFolder"]
end menu_Init


--> Display | Events
-
command mDoubleUp_GitLog indexView, someLine
   put LocalArray ["gitFolder"] into gitFolder
   
   switch word 1 of someLine
      case "commit"
         put word 2 of someLine into commitHash
         
         put commitHash & ":" & "lcw_GIT.livecode" into treeish
         put git_List (treeish, gitFolder)
         
         exit to top
         lcw_Answer merge ("Do you want to revert to checked out project [[commitHash]]?")
         
         breakpoint
         put "git checkout" && commitHash into someShell
         put git_ExecuteShellCommand (someShell, gitFolder) into shellResult
         refreshGitStatus
         break
      default
   end switch
end mDoubleUp_GitLog


--> Private
-
private command refreshGitStatus
   put LocalArray ["displayView"] into displayView
   put LocalArray ["gitFolder"] into gitFolder
   display_GitFolderStatus gitFolder, displayView
end refreshGitStatus


--> Global | GIT | Status | Menu
-
on submenu_Branch
   return "Global | GIT | Branch | Menu"
end submenu_Branch

on menu_refreshGitStatus
   stack_SaveEdited "all"
   refreshGitStatus
end menu_refreshGitStatus

on menu_DisplayStatusReport arrayView
   put LocalArray ["gitFolder"] into gitFolder
   git_DisplayStatusLines gitFolder
end menu_DisplayStatusReport

on menu_DisplayCommitHistory arrayView
   put LocalArray ["gitFolder"] into gitFolder
   put git_CurrentBranchName (gitFolder) into branchName
   put git_ExecuteShellCommand ("git log", gitFolder) into commitHistory
   display_Lines commitHistory, "git log", "mDoubleUp_GitLog", branchName
   put the result into indexView
   set the title_Menu of indexView to "Global | Git | Log | Menu"
   set the line_Menu of indexView to "Global | Git | Line | Log | Menu"
end menu_DisplayCommitHistory

on _
end _

on menu_CreateGithubProject
   -- "lcw_Git"
   put LocalArray ["shortFolder"] into repoName
   put LocalArray ["gitFolder"] into gitFolder
   --
   put lcw_Ask ("Give the new repo a name..", repoName) into repoName
   put lcw_Ask ("Give rpo a description...", "A project to interact with git and Github.") into repoDescription
   --
   github_CreateOrgRepo repoName, repoDescription
   put the result into postJSON
   put json_ToArray (postJSON) into githubProjectArray
   --
   -- put githubProjectArray ["clone_url"] into cloneURL
   -- put githubProjectArray ["git_url"] into gitURL
   -- put githubProjectArray ["html_url"] into htmlURL
   
   put githubProjectArray ["ssh_url"] into gitRemoteAddress
   -- put merge("git@github.com:LiveCodeWorld/[[shortFolder]].git") into gitRemoteAddress
   display_Array githubProjectArray
   
   git_AddFolderToRemote gitFolder, gitRemoteAddress
   put the result into addResult
   put addResult
end menu_CreateGithubProject

on menu_LaunchGithub
   -- put LocalArray ["remoteAddress"] into remoteAddress
   -- put github_FindRepoName (remoteAddress) into repoName
   put LocalArray ["shortFolder"] into repoName -- lazy
   github_Launch repoName
end menu_LaunchGithub

on menu_DisplayGithubInfo
   put LocalArray ["shortFolder"] into repoName
   display_GitHubInfo repoName
end menu_DisplayGithubInfo

on _
end _

on menu_ListTrackedFiles
   -- lists all of the already committed files being tracked by your git repo.
   -- https://stackoverflow.com/questions/8533202/list-files-in-local-git-repo
   
   put LocalArray ["gitFolder"] into gitFolder
   --
   put "git ls-tree --full-tree -r HEAD" into someShell
   -- git_ExecuteShell someShell, gitFolder
   put shell_ExecuteAtRoot (someShell, gitFolder) into shellResult
   --
   display_Index shellResult, "git ls-tree"
end menu_ListTrackedFiles

on menu_DisplayRemote
   put LocalArray ["gitFolder"] into gitFolder
   put git_GetRemoteAddress (gitFolder)
end menu_DisplayRemote

on menu_ListCommits
   put LocalArray ["gitFolder"] into gitFolder
   put git_ListCommitHashes (gitFolder)
end menu_ListCommits

on _
end _

on menu_AddAllUntracked arrayView
   set the cursor to watch
   put the displayed_GitCheckoutFolder of arrayView into gitFolder
   
   git_AddEverything gitFolder
   put the result into shellResult
   if shellResult is not empty then
      lcw_Notify shellResult
   end if
   refreshGitStatus
end menu_AddAllUntracked

on menu_StageThenCommit arrayView
   put the displayed_GitCheckoutFolder of arrayView into gitFolder
   put lcw_Ask ("Comment on this change...") into someComment
   
   git_CommitChanges someComment, gitFolder
   refreshGitStatus
end menu_StageThenCommit

on menu_AddChangesToStage
   -- dig into this. "git add --update" does not seem to do anything useful.
   breakpoint
   
   git_AddChanged
   refreshGitStatus
end menu_AddChangesToStage

on _
end _

on menu_PushCurrentBranch arrayView
   -- TO push THE new BRANCH TO A REMOTE REPOSITORY
   
   set the cursor to watch
   put the displayed_GitCheckoutFolder of arrayView into gitFolder
   put git_CurrentBranchName (gitFolder) into currentBranchName
   put "git push origin" && kwote (currentBranchName) into someShell
   
   put git_ExecuteShellCommand (someShell, gitFolder) into shellResult
   
   switch
      case shellResult begins with "Broken pipe"
         break
      case token 1 of shellResult = "Error"
         /*
         ERROR: Your account is disabled. Please see https://github.com/account/billing
         fatal: Could not read from remote repository.
         
         Please make sure you have the correct access rights
         and the repository exists.
         */
         put "Check billing" into btnText
         answer shellResult with btnText or "Cancel"
         if it is btnText then
            launch url "https://github.com/account/billing"
         end if
         break
      default
         lcw_Notify shellResult
         refreshGitStatus
   end switch
end menu_PushCurrentBranch

on menu_Pull
   -- TO PULL A new BRANCH FROM A REMOTE REPOSITORY
   -- put merge("git pull origin [[remoteBranch]]:[[newLocalBranch]]") into someShell
   -- put "git pull" into someShell
   -- put "git pull origin master" into someShell
   
   put LocalArray ["gitFolder"] into gitFolder
   
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
   
   refreshGitStatus
   
   /*
   stack_RevertLoaded
   put the result into displayView
   set the menu_Title of displayView to "Global | Git | Pull | Menu"
   */
end menu_Pull

on _
end _

on submenu_Tag
   return "Global | GIT | Tag | Menu"
end submenu_Tag

on submenu_Stash
   return "Global | GIT | Stash | Menu"
end submenu_Stash

on menu_CompactGit
   put "git gc" into someShell
   put git_ExecuteShellCommand(someShell) into shellResult
   lcw_Notify shellResult, true
end menu_CompactGit

on _
end _

on submenu_Git
   return "Global | GIT | Menu"
end submenu_Git

-- on submenu_GitFiles
return "Global | GIT | Files | Menu"
end submenu_GitFiles

on submenu_GitProjects
   return "Global | GIT | Folder | Menu"
end submenu_GitProjects

on submenu_GitSettings
   return "Global | GIT | Settings | Menu"
end submenu_GitSettings

on _
end _

on submenu_GitScript
   return "Global | GIT | Script | Menu"
end submenu_GitScript

on submenu_Gist
   return "Global | Gist | Menu"
end submenu_Gist

on menu_GitDocumentation arrayView, menuChoice
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

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_SelectProject displayView, gitProjectName
   breakpoint
   display_GitStatus gitProjectName
   
   put project_GetFolder (gitProjectName) into gitFolder
   
   put gitProjectName into LocalArray ["gitProjectName"]
   
   put the stack_Object of displayView into stackObject
   set the label of displayView to gitProjectName
end menu_SelectProject

on menu_DisplayGitProjectArray
   put git_GetProjectArray() into gitProjectArray
   display_Array gitProjectArray
end menu_DisplayGitProjectArray

on _
end _

on menu_ArrayViewScript displayView
   edit the script of displayView
end menu_ArrayViewScript

on menu_ArrayViewBehavior displayView
   put the behavior of displayView into bObject
   edit the script of bObject
end menu_ArrayViewBehavior


--> Global | GIT | Status | Menu | Props
-
getprop git_ProjectName
   put git_GetRootFolder() into gitFolder
   return gitFolder
   -- return LocalArray ["gitProjectName"]
end git_ProjectName

getprop git_ProjectNames
   put library_ListProjectNames() into projectNames
   return projectNames
end git_ProjectNames


--> Global | GIT | Status | Menu | Disabled
-
getprop disabled_CreateGithubProject [dsaf]
   put LocalArray ["gitFolder"] into gitFolder
   put git_GetRemoteAddress (gitFolder) into remoteAddress
   if remoteAddress is empty then
      return false
   else
      return true
   end if
end disabled_CreateGithubProject

-- getprop disabled_AddAllUntracked [arrayView]
put the hilited_Element of arrayView into pathItems
if LocalArray ["topKey"] = "Untracked files:" and the number of items of pathItems < 3 then
   return false
else
   return "delete"
end if
end disabled_AddAllUntracked


--> Menu | Props
-
-- getprop menu_Target [mTitlePath]
if mTitlePath contains "Global | Git | Stack | Menu" then
   return the displayed_Object of me
else if mTitlePath contains "GIT | Line | Menu" then
   put the git_Tree of me into cardTree
   put the tree_SelectedIndex of cardTree into relPathLine
   set the itemdelimiter to ":"
   switch item 1 of relPathLine
      case "unmerged"
         delete item 1 of relPathLine
         put word 1 to -1 of relPathLine into shortFile
         return git_GetRootFolder() & shortFile
      case "new file"
         delete item 1 of relPathLine
         put word 1 to -1 of relPathLine into shortFile
         return git_GetRootFolder() & shortFile
   end switch
else
   pass menu_Target
end if
end menu_Target
