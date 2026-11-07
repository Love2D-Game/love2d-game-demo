// variables to remember the player's choices
VAR second_life = false
VAR cultivation_strength = false
VAR regular_disciple = false
VAR core_disciple = false
VAR is_lone_cultivator = false
VAR friend = false
VAR friend_grudge = false
VAR elder_sus = false
VAR elder_grudge = false
VAR marked_for_grudge = false

// begin the entire story
-> village

// BRANCHES OF CHAPTER 1

=== village ===

+ Ask the local villager to explain more about this world.
    The villager tells you that there's powerful cultivation sects where cultivators group together and muderous spiritual beasts that kill in a blink of an eye.

    // learning about the world doesn't increase strength
    ~ cultivation_strength = false

    // move to Chapter 2: Choosing Your Path
    -> END

// shortest ending pathway in the game
+ Explore the village surroundings to get a reality check and observe where you are.
    It was nighttime. You slipped on wet mud from the recent rain and fell headfirst onto a sharp, up-standing wooden training sword someone carelessly left outside.

    // move to ENDING 1: The World's Most Pathetic Death
    -> END

// SECOND PLAYTHROUGH ONLY (Regression):
// players who used the time-reversal treasure retain their memories so these new options are available

+ {second_life} Use your previous life's memories to get a head start on cultivation.

    You immediately recognize the village and the confused local standing before you. Before they can explain everything, you interrupt them and start accurately describing cultivation sects, their recruitment process, and the upcoming Grand Cultivation Trial.

    The villager stares at you in utter disbelief. Despite their shock from seeing a ragged, disoriented, poor person suddenly turning clear-headed, they become convinced that you’re some powerful reincarnated immortal who has descended into the mortal world from the heavens.

    You decide not to correct their misunderstanding.

    With their newfound respect for you, they show you a secret pool of qi that was hidden in the village for you to begin cultivating in advance.

    Your aptitude in cultivation increases, and you break through the basic realm of cultivation.

    // thanks to the qi pool, player gained strength
    ~ cultivation_strength = true

    // put the END here for testing purposes only
    -> END