script "Global_GIT_Basics_Menu"
--> MetaData
-
license: GPLv3
name: Global_GIT_Basics_Menu
type: controller
version: 0.3


--> Menu | Props
-
local LocalArray

on menu_Init tObject
   put the display_View of tObject into displayView
   put displayView into LocalArray ["displayView"]
   put the title_Text of displayView into LocalArray ["shortFolder"]
   put the displayed_ScriptObject of displayView into LocalArray ["scriptObject"]
   put the displayed_GitCheckoutFolder of displayView into LocalArray ["gitFolder"]
   
   put github_ListOrgRepos() into LocalArray ["lcwRepoNames"]
end menu_Init


--> Global | GIT | Basics | Menu
-
on menu_refreshGitStatus
   stack_SaveEdited "all"
   refreshGitStatus
end menu_refreshGitStatus

on menu_Pull
   breakpoint
   
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

on menu_AddAllUntracked arrayView
   /*
   -- dig into this. "git add --update" does not seem to do anything useful.
   git_AddChanged
   */
   
   breakpoint
   
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
   breakpoint
   
   put the displayed_GitCheckoutFolder of arrayView into gitFolder
   put lcw_Ask ("Comment on this change...") into someComment
   
   git_CommitChanges someComment, gitFolder
   refreshGitStatus
end menu_StageThenCommit

on menu_PushCurrentBranch arrayView
   -- TO push THE new BRANCH TO A REMOTE REPOSITORY
   
   breakpoint
   
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


--> Global | GIT | Basics | Menu | Props
-

--> Global | GIT | Basics | Menu | Disabled
-

--> Private
-
private command refreshGitStatus
   put LocalArray ["displayView"] into displayView
   put LocalArray ["gitFolder"] into gitFolder
   display_GitFolderStatus gitFolder, displayView
end refreshGitStatus
