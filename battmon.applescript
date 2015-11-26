on isUnplugged()
    return (do shell script "ioreg -w0 -l | grep ExternalChargeCapable | awk '{print $NF}'") = "No"
end isUnplugged

on batteryPercentage()
    set Current to (do shell script "ioreg -wO -l | grep CurrentCapacity | awk '{print $NF}'")
    set Max to (do shell script "ioreg -wO -l | grep MaxCapacity | awk '{print $NF}'")
    return round (100 * Current / Max)
end batteryPercentage

global thePercentage, lastPercentage
on refreshPercentage()
    set lastPercentage to thePercentage
    set thePercentage to batteryPercentage()
end refreshPercentage
on run
    set thePercentage to 0
end run

global theVoices
on idle
    set theVoices to {"Agnes", "Albert", "Alex", "Bad News", "Bahh", "Bells", "Boing", "Bruce", "Bubbles", "Cellos", "Deranged", "Fred", "Good News", "Hysterical", "Junior", "Kathy", "Pipe Organ", "Princess", "Ralph", "Samantha", "Trinoids", "Vicki", "Victoria", "Whisper", "Zarvox"}
    set theVolume to output volume of (get volume settings)
    refreshPercentage()
    if isUnplugged() and thePercentage <= 10 then        
        if thePercentage <= lastPercentage then
            set volume output volume 100
            try -- "Samantha" produces an error on my machine.
                say (Percentage as string) & "%" using (some item of theVoices)
            end try
            set volume output volume theVolume
        end if
        if thePercentage <= 5 then
            repeat 10 times
                set volume output volume 100
                say "Low Battery"
                set volume output volume theVolume
                repeat 10 times
                    if not isUnplugged() then exit repeat
                    set volume output volume 100
                    beep
                    set volume output volume theVolume
                end repeat
                if not isUnplugged() then exit repeat
            end repeat
        end if
    end if
end idle