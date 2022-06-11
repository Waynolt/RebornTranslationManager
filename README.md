This is a tranlation manager for Pokemon fangames, developed to more handily translate Pokemon Reborn.

To install, simply extract everything in your Reborn folder (where the file Game.exe is located)

SAVE OFTEN!

Also, selecting another language without saving the changes will discard them.

Questions:
Q0. What happens if a new episode comes out? Do we have to re-make the translation?
A0. Not really: just click on "Import translated lines" and select the old .txt translation file - the manager will then try to import every unchanged line in the new episode (provided you already used the debug menu to extract the game's text, creating the intl.txt file for the new episode).

Q1. Do I have to do translate everything on my own?
A1. No: you can agree on a section to translate (e.g. lines from 0 to 1000) and then Import->Merge the sections translated by someone else.

Q2. My game takes a long time to load up after saving a translation.
A2. That's because it is compiling the edited translation.
It has to be the game the one to compile it because the manager is written in Pascal, the game is in Ruby, and the workaround would be too much hassle.
Also, please notice that it will only compile it once per edit - if you don't change the translation, then it doesn't re-compile it.

Q3. The manager became blue!
A3. It's its way of telling you that it's busy. Just wait, it will get back to normal (or freeze , but there's no easy way of telling if it froze without waiting).

Q4. This program created some files!
A4. Yep. Besides the translation files for each language (duh), it creates two mods in the Data\Mods folder: a Languages file that informs the game of which languages are installed and a Languages_Compile file that compiles them (see question 2).

Q5. There are still untranslated lines in the game!
A5. Some lines cannot be translated without changing the game's scripts and then recompiling everything in it, which is best left as a task for later.

Q6. These "questions" don't really look like questions...
A6. I know :(
