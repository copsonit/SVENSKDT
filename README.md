# SVENSKDT
Application for Atari Falcon 030 that installs swedish desktop and keyboard. 

This is the source code used for creating the "Svensk Desktop" for Falcon.
It was developed by Copson DATA, Sweden and sold to the Swedish distributor
for Atari at that time, AdAstra AB, and was delivered with all Swedish
sold Atari Falcons during about 1994-1995 until AdAstra AB stopped trading.

It is release to public domain 2020 by me, Conny Pettersson, as the developer
of the software.

The repo will try to recreate the development cycle as well as the commits should
be in the order the files were originally created by changing the last file
number and thus keeping a history of the files.

Idea
----

When Falcon 030 was released with TOS 4.x, it was a considerably larger sized
ROM that was used compared to previous models of Atari. This also made it
possible to have room for multiple languages. It had english, german, french
and so on and it was possible to change the language with a setting in the
NV_RAM.
The setting was prepared for more languages, such as Swedish, but probably
lack of resources didnt make any Swedish translations to the final ROMs.
This is where Copson DATA comes in and saves the day! After investigating
how the switching takes place, it seemed possible to insert additional
languages with the same priciples, i.e. switching the NV_RAM to Swedish
and then pointing to Swedish resource files.
This was done i a prototype and the idea was presented to AdAstra AB and
they went ahead with it and Copson DATA developed the program and sent
floppys to AdAstra who then distributed them with each Swedish sold Falcon.


Details about the source
------------------------

The original files were kept in the structure D:\GEN_MON\F030\TOS_SWED and
D:\GEN_MON\F030\SET_NVM. These subdirectories exists here both under the
SVENSKDT repo. In the source files it probably refers to the absolute paths
so they have to be adjusted to be able to recompile everything again.

The first commits were taken from sources done 19th Jan 1994 according to
original timestamps of the files.

The process started with extracting the RSC files from the BIN files in the
Swedish TOS 3.06, which was the latest closest we had for TOS 4.04 in Swedish.
I then extracted similar english RSC from the US TOS 4.04 and translated
everything as identical as possible from TOS 3.06.

I then had a utility program called MAKESWED.S which combined the two RSC
files and the INF, which also had to be translated, to a BIN file in the
same format as it was placed in the TOS. Looking briefly at the program,
it looks like it just loads three files and place them after each other and
saves them as one file. I cannot really see any changing of the files done.



