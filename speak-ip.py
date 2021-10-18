import os
import sys
import time
import netifaces as ni
from subprocess import call

INTERFACE_NAME = os.environ['INTERFACE_NAME']

def debug(s):
  #print(s)
  #sys.stdout.flush()
  pass
  
def ipv4_to_speech(ipv4):
  nums = ipv4.split('.')
  out = ''
  for n in nums:
    s = str(n)
    for c in s:
      out += (c + ' ')
    out += 'dot '
  return out[:-4]

ipv4 = ni.ifaddresses(INTERFACE_NAME)[ni.AF_INET][0]['addr']
debug('ipv4="%s"' % ipv4)

speakable = ipv4_to_speech(ipv4)
debug('speakable="%s"' % speakable)

MESSAGE = 'Your eye pee address is ' + speakable
debug(MESSAGE)

COMMAND = 'espeak -g 8 "' + MESSAGE + '" >/dev/null 2>&1'
print(MESSAGE)
sys.stdout.flush()
while True:
  call([COMMAND], shell=True)
  time.sleep(30)

