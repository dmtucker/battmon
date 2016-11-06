on isUnplugged()
    return (do shell script "ioreg -w0 -l | grep ExternalChargeCapable | awk '{print $NF}'") = "No"
end isUnplugged

on batteryPercentage()
    set Current to (do shell script "ioreg -wO -l | grep CurrentCapacity | awk '{print $NF}'")
    set Max to (do shell script "ioreg -wO -l | grep MaxCapacity | awk '{print $NF}'")
    return round (100 * Current / Max)
end batteryPercentage

global thePercentage, lastPercentage, lowPercentage, criticalPercentage
on refreshPercentage()
    set lastPercentage to thePercentage
    set thePercentage to batteryPercentage()
end refreshPercentage

global alertVolume
on run
    set theTitle to "Battery Monitor"
    set theIntro to "This application audibly alerts you when your battery becomes low or critical. When the battery is low, a random voice will announce the battery level whenever it changes. When the battery is critical, alerts will increase to continuous warnings and beeps. Alerts only occur when the computer is unplugged."
    display dialog theIntro with title theTitle
    display dialog "What volume % should alerts be played at?" default answer "100" with title theTitle
    set alertVolume to the text returned of the result as number
    display dialog "What battery % is low?" default answer "10" with title theTitle
    set lowPercentage to the text returned of the result as number
    display dialog "What battery % is critical?" default answer "5" with title theTitle
    set criticalPercentage to the text returned of the result as number
    set thePercentage to batteryPercentage()
end run

on idle
    if isUnplugged() then
        set theVoices to {"Agnes", "Albert", "Alex", "Bad News", "Bahh", "Bells", "Boing", "Bruce", "Bubbles", "Cellos", "Deranged", "Fred", "Good News", "Hysterical", "Junior", "Kathy", "Pipe Organ", "Princess", "Ralph", "Samantha", "Trinoids", "Vicki", "Victoria", "Whisper", "Zarvox"}
        set theVolume to output volume of (get volume settings)
        refreshPercentage()
        if thePercentage ≤ lowPercentage and thePercentage ≤ lastPercentage then
            set volume output volume alertVolume
            try -- "Samantha" produces an error on my machine.
                say (thePercentage as string) & "%" using (some item of theVoices)
            end try
            set volume output volume theVolume
        end if
        if thePercentage ≤ criticalPercentage then
            repeat 10 times
                set volume output volume alertVolume
                say "Low Battery"
                set volume output volume theVolume
                repeat 10 times
                    if not isUnplugged() then exit repeat
                    set volume output volume alertVolume
                    beep
                    set volume output volume theVolume
                end repeat
                if not isUnplugged() then exit repeat
            end repeat
        end if
    end if
end idle
