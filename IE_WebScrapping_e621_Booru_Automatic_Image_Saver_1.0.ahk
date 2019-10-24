#SingleInstance,Force

InputBox, NumArtists, Enter Amount of "e621.net" Artists:, Enter The Number of "e621.net" Artists Galleries You Will be Saving This Session (# From 1 - Infinite).,, 620
Artists := []
SaveTo := []
loop % NumArtists
{
InputBox, Artist, Enter Artist Name: # %A_Index%, Enter the username of the artist as it would appear on the website's search engine.,, 550
Artists[A_Index] := Artist

InputBox, SaveWhere, Enter Save File Directory: # %A_Index%, Enter the File Directory you want this artists images to be saved in (EXACT DIR).,, 520
SaveTo[A_Index] := SaveWhere
}

wb := ComObjCreate("InternetExplorer.Application")
wb.Visible := True
sleep, 200
loop % NumArtists                                                                           ;loop starts here, change variables that are changing to arrays and see how it turns out.
{
    SubFunCnt := A_Index
    global UqImgNum := 0                                                                    ;Don't Change
    global navPage := 1                                                                     ;Change
    Artistary := Artists[SubFunCnt]
    nav := "https://e621.net/post/index/" . navPage . "/" . Artistary                       ;Don't Change
    wb.Navigate(nav)

    IELoad(wb)
    sleep, 400

    RestartPoint:
    Pic_URLs := []				                                                            ;Array holding the Picture Redirect URLs
    End_Marker := wb.Document.getElementsByTagName("title")[0].InnerHTML
    ObtainImgURL(Pic_URLs, wb)
    Stp := (wb.Document.queryselectorAll("a[href*='/post/show/']").length) -1
    MainSaveFun(Pic_URLs, wb, Artistary, SaveTo, nav, Stp, SubFunCnt)                       ;Calls MainSaveFun, which will do image saving. When function ends, appears to start back from where it was called.
    if (End_Marker = "e621 - e621")
    {    
        continue
    }
    else
    {
        goto, RestartPoint                                                                  ;Probably will turn into a "continue" command for the loop, which essentially does the same thing inside a loop.
    }
}
SoundPlay, C:\Users\KirkO\Desktop\Kirk Backup Files\Kirk's Files\Audio Files\SUCKMYDICK.wav ;Plays Audio File from collection to know when program has ended, maybe try have it text me or something as well.
sleep, 2250                                                                                 ;Pause Allows Audio File to Play Fully.
Exit

;________________Functions


MainSaveFun(Pic_URLs, wb, Artistary, SaveTo, nav, Stp, SubFunCnt)                           ;Main function that will be used for saving images after going to full-res images
{
    Cnt := wb.Document.queryselectorAll("a[href*='/post/show/']")
    loop % Cnt.length
    {
        c := A_Index -1
        global UqImgNum := UqImgNum + (A_Index)                              ;Allows every File name to have a different number for this running cycle, so files do not override while saving, (Not pretty, but works).
        wb.Navigate(Pic_URLs[A_Index -1])                                    ;Cycles Through the pages URL array, +1 every cycle of loop.
        IELoad(wb)
        sleep, 100
        qt := wb.Document.getElementById("highres").getAttribute("href")     ;Finds the high-res URL source of the image on page.
        SetWorkingDir % SaveTo[SubFunCnt]                                    ;Sets Location that file will be saved to.
        qtExt := SubStr(qt, -2)
        if qtExt in jpg,peg,png
        {
            URLDownloadToFile % qt, %Artistary%_Art_%UqImgNum%.png
            sleep, 300
        }
        else if qtExt in gif
        {
            URLDownloadToFile % qt, %Artistary%_Art_%UqImgNum%.gif
            sleep, 300
        }
        else if qtExt in swf
        {
            URLDownloadToFile % qt, %Artistary%_Art_%UqImgNum%.swf
            sleep, 800
        }
        else if qtExt in ebm,avi,flv,mp4,mpg,wmv
        {
            URLDownloadToFile % qt, %Artistary%_Art_%UqImgNum%.avi
            sleep, 1000
        }
        else
        {
            FileAppend, Invalid File Format, %Artistary%_Art_%UqImgNum%.txt
            sleep, 200
        }
        
        if (Stp = c)
        {
            global navPage := navPage + 1
            nav := "https://e621.net/post/index/" . (navPage -1) . "/" . Artistary
            wb.Navigate(nav)
            IELoad(wb)
            Try                      ;This Try "loop" is here because tags without more than 1 page of images does not have the 'next_page' class and would cause an error, this is meant to deal with those.
            {
                qm := wb.Document.getElementsByClassName("next_page")[0].getAttribute("href")
                qm := "https://e621.net" + qm
                wb.Navigate(qm)
                IELoad(wb)
                sleep, 400
                return
            }
            catch e
            {
                hm := "https://e621.net"
                wb.Navigate(hm)
                IELoad(wb)
                sleep, 400
                return
            }
        }
    }
}


ObtainImgURL(Pic_URLs, wb)
{
Links := wb.Document.queryselectorAll("a[href*='/post/show/']")
loop % Links.length
    {
        i := A_Index - 1
        Pic_URLs.Push(Links[i].href)
    } ;until !(i < 80)
RemovedValue := Pic_URLs.RemoveAt(0)                                     ;Used to remove first empty spot of array since values are appended and push one space to being empty
}


IELoad(wb)                                                               ;You need to send the IE handle to the function unless you define it as global.
{
    If !wb    ;If wb is not a valid pointer then quit
        Return False
    Loop    ;Otherwise sleep for .1 seconds untill the page starts loading
    {
        Sleep,100
        if (A_Index = 95)                                                ;Hopefully a quick fix for any random hang-ups on page loading
            wb.Refresh()
    }Until (wb.busy)
    
    Loop    ;Once it starts loading wait until completes
    {
        Sleep,100
        if (A_Index = 95)                                               ;Hopefully a quick fix for any random hang-ups on page loading
            wb.Refresh()
    }Until (!wb.busy)
    
    Loop    ;optional check to wait for the page to completely load
    {
        Sleep,100
        if (A_Index = 95)                                               ;Hopefully a quick fix for any random hang-ups on page loading
            wb.Refresh()
    }Until (wb.Document.Readystate = "Complete")
Return True
}