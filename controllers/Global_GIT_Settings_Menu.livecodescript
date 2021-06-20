script "Global | GIT | Settings | Menu"
--> MetaData
-
license: GPLv3
name: Global | GIT | Settings | Menu
type: controller
version: 0.2


--> Menu | Init
-
local LocalArray

getprop menu_Target [tObject]
   put the display_View of tObject into displayView
   --
   put the title_Text of displayView into projectName   
   put projectName into LocalArray ["projectName"]
   --
   put env_ConstructProjectFolder (projectName) into projectFolder    
   put git_LocalIgnoreFile (projectFolder) into ignoreFile
   put there is a file ignoreFile into LocalArray ["localIgnoreExists"]
   --
   return projectFolder
end menu_Target

getprop documentation_Params
   return the hkey_CaseConditions ["M menu_Documentation"] of me
end documentation_Params
   
getprop disabled_CreateLocalGitIgnoreFile [projectFolder]
   return LocalArray ["localIgnoreExists"]
end disabled_CreateLocalGitIgnoreFile

getprop disabled_EditLocalGitIgnoreFile [projectFolder]
   return LocalArray ["localIgnoreExists"] is false
end disabled_EditLocalGitIgnoreFile

getprop disabled_CreateGlobalGitIgnoreFile [projectFolder]
   put git_GlobalIgnoreFile (projectFolder) into ignoreFile
   put there is not a file ignoreFile into noGlobalIgnore
   return noGlobalIgnore
end disabled_CreateGlobalGitIgnoreFile

getprop overwriteIgnoreFile_Params [projectFolder]
   return "Global,Local"
end overwriteIgnoreFile_Params

getprop testIgnoreFile_Params [projectFolder]
   return "Global,Local"
end testIgnoreFile_Params


--> Global | GIT | Settings | Menu
-
on menu_DisplayGitRemote projectFolder
   put git_GetRemoteAddress (projectFolder) into remoteAddress
   --
   put remoteAddress
   /*
   put LocalArray ["projectName"] into projectName
   put merge ("Edit the remote address for repo [[projectName]]...") into someQuestion
   put lcw_Ask (someQuestion, remoteAddress)
   */
end menu_DisplayGitRemote

on menu_DisplayGitConfig
   put git_ExecuteShellCommand("git config --list") into shellResult
   --
   display_Text shellResult, "git config --list"
end menu_DisplayGitConfig

on menu_Documentation projectFolder, whichDoc
   switch whichDoc
      case "Git Ignore"
         launch url "https://docs.github.com/en/free-pro-team@latest/github/using-git/ignoring-files"
         break
      case "Git Config"
         break
   end switch
end menu_Documentation

on _
end _

on menu_CreateLocalGitIgnoreFile projectFolder
   put git_LocalIgnoreFile (projectFolder) into ignoreFile
   lcw_Answer "Create and edit new local .ignore file in the local project directory?"
   --
   git_CreateLocalIgnoreFile projectFolder
   put the result into shellResult
   return ignoreFile
end menu_CreateLocalGitIgnoreFile

on menu_EditLocalGitIgnoreFile projectFolder
   put git_LocalIgnoreFile (projectFolder) into ignoreFile
   atom_DisplayFile ignoreFile
end menu_EditLocalGitIgnoreFile

on menu_AddGitIgnore
   -- git add .gitignore
end menu_AddGitIgnore

on _
end _

on menu_CreateGlobalGitIgnoreFile projectFolder
   put git_GlobalIgnoreFile() into ignoreFile
   answer "Create and edit new global .ignore file in the $HOME directory?" with "Cancel" and "OK"
   if it is "Cancel" then exit to top
   --
   git_CreateGlobalIgnoreFile projectFolder
   put the result into ignoreFile
end menu_CreateGlobalGitIgnoreFile

on menu_EditGlobalGitIgnoreFile
   put git_GlobalIgnoreFile() into ignoreFile
   if there is not a file ignoreFile then
      answer "Create and edit new global .ignore file in the $HOME directory?" with "Cancel" and "OK"
      if it is "Cancel" then exit to top
      git_CreateIgnoreFile true, pIgnoreType
   end if
   
   display_TextFile ignoreFile, "Git Ignore Files"
   atom_Edit ignoreFile
end menu_EditGlobalGitIgnoreFile

on _
end _

on menu_ConfigureGitLogin
   put user_GetLogin() into userName
   put lcw_Ask("GIT user name...", userName) into userName
   --
   put "git config --global user.name" && kwote(userName) into someShell
   put git_ExecuteShellCommand (someShell) into shellResult
   --
   display_Text shellResult, "git config --list"
end menu_ConfigureGitLogin

on menu_ConfigureGitEmail
   put user_GetEmail() into userEmail
   put lcw_Ask("GIT user email...", userEmail) into userEmail
   --
   put "git config --global user.email" && kwote(userEmail) into someShell
   put git_ExecuteShellCommand(someShell) into shellResult
   --
   display_Text shellResult, "git config --list"
end menu_ConfigureGitEmail

on menu_IgnoreWhiteSpace
   get git_ExecuteShellCommand("git config --global apply.whitespace nowarn")
   if it is not empty then lcw_Notify it, true
   --
   put git_ExecuteShellCommand ("git config --list") into shellResult
   display_Text shellResult, "git config --list"
end menu_IgnoreWhiteSpace

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_OverwriteIgnoreFile gitFolder, menuChoice
   set the cursor to watch
   switch menuChoice
      case "Global"
         git_CreateIgnoreFile true
         put the result into ignoreFile
         break
      case "Local"
         git_CreateIgnoreFile
         put the result into ignoreFile
         break
   end switch
   display_TextFile ignoreFile, "Git Ignore Files"
   git_RefreshDisplay
end menu_OverwriteIgnoreFile

on menu_TestIgnoreFile gitFolder, menuChoice
   switch menuChoice
      case "Global"
         put git_GlobalIgnoreFile() into ignoreFile
         break
      case "Local"
         break
         put git_GlobalIgnoreFile() into ignoreFile
   end switch
   
   put url ("binfile:" & ignoreFile) into ignoreText
   put text_LineEndingPlatform (ignoreText) into somePlatform
   lcw_Notify somePlatform, true
end menu_TestIgnoreFile

on menu_FixGitIgnoreFile
   put git_GlobalIgnoreFile() into ignoreFile
   
   put "binfile:" & ignoreFile into someUrl
   put url someUrl into ignoreText
   replace CR with empty in ignoreText
   put ignoreText into url someUrl
end menu_FixGitIgnoreFile


--> Deps
-
function text_LineEndingPlatform someText
   if someText contains CRLF then
      return "Windows"
   else if someText contains LF then
      return "Unix"
   else if someText contains CR then
      return "Mac"
   else
      return empty
   end if
end text_LineEndingPlatform
