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
getprop menu_Target [mTitlePath]
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


--> Global | GIT | Status | Menu
-
on menu_SelectProject indexView, gitProjectName
   display_GitStatus gitProjectName
   
   put project_GetFolder (gitProjectName) into gitCheckoutFolder
   
   git_SetRootFolder gitCheckoutFolder
   put gitCheckoutFolder into LocalArray ["gitCheckoutFolder"]
   put gitProjectName into LocalArray ["gitProjectName"]
   
   put the stack_Object of indexView into stackObject
   set the label of stackObject to gitProjectName
end menu_SelectProject

on menu_AddAllUntracked
   -- put the shiftKey is "Down" into shiftStatus
   set the cursor to watch
   
   put LocalArray ["gitProjectName"] into gitProjectName
   put LocalArray ["gitCheckoutFolder"] into gitCheckoutFolder
   
   put "git add --all" into someShell
   put git_ExecuteShellCommand (someShell, gitCheckoutFolder) into shellResult
   
   lcw_Notify shellResult
   -- if shiftStatus is false then git_RefreshDisplay
   display_GitStatus gitProjectName
end menu_AddAllUntracked

on menu_StageThenCommit
   -- put the shiftKey is "Down" into shiftStatus
   put LocalArray ["gitProjectName"] into gitProjectName
   put LocalArray ["gitCheckoutFolder"] into gitCheckoutFolder
   
   put lcw_Ask ("Comment on this change...") into someComment
   git_CommitChanges someComment, gitCheckoutFolder
   
   put the result
   lcw_Notify "Commited changes..."
   
   -- git_RefreshDisplay "Git Status"
   display_GitStatus gitProjectName
end menu_StageThenCommit

on menu_AddChangesToStage
   git_AddChanged
   display_GitStatus
end menu_AddChangesToStage

on _
end _

on menu_PushCurrentBranch
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
   dispatch "library_StopEnvironment" to stack "OPN"
   dispatch "library_StartEnvironment" to stack "OPN"
   
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

on submenu_GitProjects
   menu_DoSub "Global | GIT | Folder | Menu"
end submenu_GitProjects

on submenu_GitSettings
   return "Global | GIT | Settings | Menu"
end submenu_GitSettings

on menu_GitDocumentation menuChoice
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

on _
end _

on menu_StackHistoryMenu
   set the menu_Title of the card_Tree of me to "Stack | History | Menu"
end menu_StackHistoryMenu

-- on submenu_Development
return "GIT | Dev | Menu"
 submenu_Development


--> Global | GIT | Status | Menu | Props
-
getprop git_ProjectName
   return LocalArray ["gitProjectName"]
end git_ProjectName

getprop git_ProjectNames
   put library_ListProjectNames() into projectNames
   return projectNames
end git_ProjectNames
