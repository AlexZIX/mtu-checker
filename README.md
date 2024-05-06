# MTU-Сhecker
This project is a tool which allows to listen and send TCP and UDP packets of different sizes for checking MTU and other network parameters

# Description
Usually system administrators use ping for checking MTU values while tracing packets from one host to another. It's useful but doesn't cover all network issues related to the MTU. For ex. MTU issue in flannel network plugin for docker (see https://github.com/flannel-io/flannel/issues/1011). It just takes the interface MTU, decrease it to 50 and use. In our case we use IPSec between remote locations. Interface MTU was 1500 and tunnel MTU only 1372 which smaller than 1450 which flannel use in this case. Ping between hosts shows us the real MTU, but flannel just drops all packets with MTU exceeds 1320. We found it only due to this tool which can start as a server at one side and as client which sending packts of different sizes at another.

# How to use
Usage: tmc [OPTIONS]  
Possible options:  
-s - server mode  
-c - client mode  
-u - use UDP instead of TCP. Default: use TCP  
-p - port (both modes). Default: 2233  
-h host - specify host for connection (client mode). Default: 127.0.0.1  
  
Send one packet of specified size  
-m size (bytes) - send one packet of specified size (client mode)  
  
Send set of packets from size x to size y with step z  
-x size (bytes) - size of 1st packet for random generator (client mode)  
-y size (bytes) - size of last packet for random generator  
-z step (bytes) - increment step for random generator  
  
# Where it works
Windows x64 (tested on Windows 10)
Linux x64 (tested on Ubuntu Server 22.04)

# How to compile
Tool written in Delphi 11 Alexandria using Indy 
