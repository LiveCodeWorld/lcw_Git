﻿script "Global_GIT_Status_Menu"
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
   put the displayed_ScriptObject of displayView into LocalArray ["scriptObject"]
   put the displayed_GitCheckoutFolder of displayView into LocalArray ["gitCheckoutFolder"]
end menu_Init


--> Private
-
private command refreshGitStatus
   put LocalArray ["displayView"] into displayView
   put LocalArray ["gitCheckoutFolder"] into gitCheckoutFolder
   display_GitFolderStatus gitCheckoutFolder, displayView
end refreshGitStatus


--> Global | GIT | Status | Menu
-
on submenu_Branch
   return "Global | GIT | Branch | Menu"
end submenu_Branch

on menu_refreshGitStatus
   refreshGitStatus
end menu_refreshGitStatus

on menu_DisplayStatusReport arrayView
   put LocalArray ["gitCheckoutFolder"] into gitCheckoutFolder
   git_DisplayStatusLines gitCheckoutFolder
end menu_DisplayStatusReport

on _
end _

on menu_AddAllUntracked arrayView
   set the cursor to watch
   put the displayed_GitCheckoutFolder of arrayView into gitCheckoutFolder
   
   git_AddEverything gitCheckoutFolder
   put the result into shellResult
   if shellResult is not empty then
      lcw_Notify shellResult
   end if
   refreshGitStatus
end menu_AddAllUntracked

on menu_StageThenCommit arrayView
   put the displayed_GitCheckoutFolder of arrayView into gitCheckoutFolder
   put lcw_Ask ("Comment on this change...") into someComment
   
   git_CommitChanges someComment, gitCheckoutFolder
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

on menu_PushCurrentBranch
   breakpoint
   
   -- TO push THE new BRANCH TO A REMOTE REPOSITORY
   
   set the cursor to watch
   put git_CurrentBranchName() into currentBranchName
   put "git push origin" && kwote(currentBranchName) into someShell
   
   put git_ExecuteShellCommand(someShell) into shellResult
   
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
         lcw_Notify shellResult, true
         display_GitStatus
   end switch
end menu_PushCurrentBranch

on menu_Pull
   -- TO PULL A new BRANCH FROM A REMOTE REPOSITORY
   -- put merge("git pull origin [[remoteBranch]]:[[newLocalBranch]]") into someShell
   -- put "git pull" into someShell
   -- put "git pull origin master" into someShell
   put git_CurrentBranchName() into currentBranchName
   put "git pull origin" && kwote(currentBranchName) into someShell
   
   put git_ExecuteShellCommand(someShell) into shellResult
   display_Lines shellResult, someShell
   
   stack_RevertLoaded
   
   put the result into displayView
   set the menu_Title of displayView to "Global | Git | Pull | Menu"
end menu_Pull

on _
end _

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
   
   put project_GetFolder (gitProjectName) into gitCheckoutFolder
   
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
   put git_GetRootFolder() into gitCheckoutFolder
   return gitCheckoutFolder
   -- return LocalArray ["gitProjectName"]
end git_ProjectName

getprop git_ProjectNames
   put library_ListProjectNames() into projectNames
   return projectNames
end git_ProjectNames


--> Global | GIT | Status | Menu | Disabled
-
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