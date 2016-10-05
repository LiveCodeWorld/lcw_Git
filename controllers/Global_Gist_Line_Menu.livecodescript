script "Global_Gist_Line_Menu"
--> MetaData
-
license: GPLv3
name: Global_Gist_Line_Menu
type: controller
version: 0.1


--> Global | Gist | Line | Menu
-
on menu_LaunchGist indexView
   put the clickText
end menu_LaunchGist

on _
end _

on menu_TestGistIsSame shortController  
   put rig_FetchController (shortController) into serverRigScript
   put rig_FetchGistController (shortController) into gistRigScript
   if serverRigScript = gistRigScript then
      answer "Gist is the same as the servers controller."
   else
      answer "Gist differs from the servers controller."
   end if
end menu_TestGistIsSame

on menu_DeleteGist shortController
   answer warning merge ("Are you sure you want to delete the controller '[[shortController]]'?") with "OK" and "Cancel"
   if it is "Cancel" then exit to top
   
   set the cursor to watch
   rig_DeleteGistController shortController
   get the result
   switch
      case word 1 to 2 of it = "socket timeout"
         put it
         -- but often already deletes it
         send "refresh" to me in 2 ticks
         break
      case word 1 of it = "error"
         -- usually a 404 as it has already been deleted
         put it
         refresh
         break
      default
         put the hilitedline of me into lineNum
         delete line lineNum of me
   end switch
end menu_DeleteGist
