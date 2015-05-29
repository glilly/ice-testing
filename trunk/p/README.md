ice-testing
===========

Testing of ICE Immunization Forecasting for VistA

The code for the ICE/VistA Immunization Forecasting Prototype on github here:

https://github.com/glilly/ice-testing/tree/master/trunk/p

The code is written in the C0I namespace

The soap processor that I'm currently using is SOAP^C0ISOAP3

https://github.com/glilly/ice-testing/blob/master/trunk/p/C0ISOAP3.m

The current DOMO (DOM Out processor) that I'm using is domo3^C0IEXTR

https://github.com/glilly/ice-testing/blob/master/trunk/p/C0IEXTR.m

And the processor I use on the output of DOMO to simplify it is 
d peel^C0IUTIL("RETURN","GPL")

https://github.com/glilly/ice-testing/blob/master/trunk/p/C0IUTIL.m

It would be great to have any or all of these functions available in 
the Kernel.

You can see these utilities in action on my ice development system:

( if you are behind the VA firewall, port 80 is available and all these 
URLs will begin with http://ice.vistaewd.net/ice .... 
from outside the VA firewall,  we have blocked port 80 due to spamming 
and all the URLs will begin with http://ice.vistaewd.net:9080/ice )

Here is the XML returned by the SOAP call (unwrapped from the SOAP envelop 
and decoded from base64 decoding)
This output would be appropriate to send eHMP via web service or an RPC call. 

http://ice.vistaewd.net/ice/11?format=xml

Here is the output of domo3 from the same xml:

http://ice.vistaewd.net:9080/ice/11?format=global
http://ice.vistaewd.net/ice/11?format=global

Here is the output of peel :

http://ice.vistaewd.net:9080/ice/11?format=simple
http://ice.vistaewd.net/ice/11?format=simple

And here is the final report along with the RETURN array, which contains 
everything you see from peel as well as the VistA data which links to it... 

http://ice.vistaewd.net:9080/ice/11?format=report&debug=1
http://ice.vistaewd.net/ice/11?format=report&debug=1

you can also try patient 58 or 5 instead of 11 to see some of the variety that is here...