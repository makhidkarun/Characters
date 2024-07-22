# T5 CHARACTER GENERATOR

SYNOPSIS
   perl t5chargen.pl [career=CAREER] [DNA=xxx] [UPP=ssahpgl-t] [terms=TERMS] [count=COUNT] [name=NAME] [quiet=1]

CAREER: one of random, Agent, Citizen, Craftsman, Entertainer, Functionary, Marine, Merchant, Noble, Rogue, Scholar, Scout, Soldier, or Spacer.  Default is Soldier. 'random' gets you a random career.

DNA: The three physical genetic 1D rolls.

UPP: The full UPP of the character.  Default is random.

TERMS: If you want to force the number of terms you want the character to have gone through.

COUNT: The number of characters to generate.

NAME: The character's name.

quiet: Only prints the results. Default is to show the process.


# CREW GENERATOR

SYNOPSIS
   perl crew.pl

This script will iteratively run the above t5chargen.pl until a full crew is found.
