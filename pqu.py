import os
import string

def wrap (num):
    #openTag = "${color3}"
    openTag = "^fg($DZEN_FG3)"
    #closeTag = "${color}"
    closeTag = "^fg()"

    if num == 0:
        return str (num)
    else:
        return openTag + str (num) + closeTag


com = "pacman -Qu|wc -l"

temp = os.popen (com)
msg = temp.read ()

fc = int (msg)
print (str (fc))

#com2 = "yaourt -Qu|wc -l"
#temp2 = os.popen (com2)
#msg = temp2.read ()

#fc2 = int (msg) - fc

#print (wrap (fc) + " / " + wrap (fc2))
