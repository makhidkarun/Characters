package Homeworld;
use strict;
use warnings;

###############################################################################
#
#  Homeworld Skills
#
#  Meh. Why box them in? Let the player decide.
#
###############################################################################
sub setHomeworldSkills
{
   my $charref = shift;
   my $homeworld = getHomeworld();
   my @homes = keys %$homeworld;

   my $home = $homes[ rand @homes ];
   my $skills = $homeworld->{ $home };
  
   Skills::addSkill( $charref, $_ ) foreach @$skills;
   
   return "Homeworld: \u$home.  Skills: " . join( ", ", @$skills ) . "\n";
}

sub getHomeworld
{
   return 
   {
      'allel' => [ 'Trader', 'Art' ], 
	  'boughene' => [ 'Hostile_Env', 'Driver' ], # boughene
	  'capital' => [ 'Streetwise', 'Language' ], # capital
	  'dorannia' => [ 'Hostile_Env', 'Driver', 'Steward' ], # dorannia
	  'efate' => [ 'Streetwise', 'Trade' ], # efate
	  'feri' => [ 'Trader', 'Art' ], # feri
	  'magash' => [ 'Vacc_Suit', 'Streetwise', 'Survey', 'Trade', 'Admin' ], # magash
	  'hefry' => [ 'Vacc_Suit', 'Driver' ], # hefry
	  'jenghe' => [ 'Driver' ], # jenghe
	  'earth' => [ 'Trader', 'Streetwise' ], # earth
	  'lakou' => [ 'Driver' ], # lakou
	  'macene' => [ 'Zero-G', 'Driver' ], # macene
	  'knorbes' => [ 'Animals', 'Art' ], # knorbes
	  'preslin' => [ 'Survival', 'Driver', 'Survey', 'Steward' ],
	  'yori' => [ 'Survival', 'Art' ],
	  'regina' => [ 'Trader', 'Art', 'Bureaucracy' ],
	  'ruie' => [ 'Streetwise', 'Trade' ],
	  'tremous Dex' => [ 'Vacc Suit', 'Driver' ],
	  'uakye' => [ 'Driver' ],
	  'vland' => [ 'Streetwise', 'Bureaucracy' ],
	  'wroclaw' => [ 'Animals', 'Art' ],
	  'menorb' => [ 'Streetwise', 'Steward' ],
	  'yorbund' => [ 'Hostile_Env', 'Driver' ],
	  'traltha' => [ 'Survival', 'Hostile_Env', 'Driver' ],
	  'dentus' => [ 'Driver' ],
	  'vanzeti' => [ 'Seafarer', 'Driver' ],
	  'Syr Darya' => [ 'Driver', 'Animals' ],
	  'aramis' => [ 'Hostile_Env', 'Driver', 'Admin' ],
	  'rhylanor' => [ 'Streetwise', 'Admin' ],
	  'raschev' => [ 'Art' ],
	  'ara Pacis' => [ 'Driver' ],
	  'roup' => [ 'Seafarer', 'Streetwise', 'Trade' ],
	  'pax Rulin' => [ 'Vacc_Suit', 'Vacc_Suit', 'Flyer', 'Admin' ],
	  'space' => [ 'Survey', 'Vacc_Suit' ]
   };
}

