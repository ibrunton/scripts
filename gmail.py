import os
import sys
import string

if (len (sys.argv) > 1):
    username = sys.argv[1]
else:
    print ("No username specified")

def wrap (num):
    openTag = "^fg($DZEN_FG3)"
    #openTag = "${color3}"
    closeTag = "^fg()"
    #closeTag = "${color}"

    if num == 0:
        return str (num)
    else:
        return openTag + str (num) + closeTag


com = "curl --connect-timeout 1 -m 3 -fs --netrc-file /home/ian/.config/netrc_" + username + " https://mail.google.com/mail/feed/atom/"

try:
    temp = os.popen (com)
    msg = temp.read()
    f = open ('/home/ian/.local/share/inbox_' + username, 'w')
    f.write (msg)
    f.close ()
    index = str.find (msg,"<fullcount>")
    index2 = str.find (msg,"</fullcount>")
    fc = msg[index+11:index2]

    if fc:
        print (fc)
    else:
        print ("-1")

except:
    print ("-1")
