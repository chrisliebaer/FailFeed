![Stading in Fire: Bad](https://raw.githubusercontent.com/chrisliebaer/FailFeed/master/.github/assets/badge/badge_fire.svg)

FailFeed is a World of Warcraft addon for Mythic+ that displays a "kill"-feed of the stuff your boosted monkey team mates are taking avoidable damage from.
Similar to [ElitismHelper](https://github.com/amki/ElitismHelper) but just for you without spaming the chat.
In fact most of the internal spell database is taken from ElitismHelper.

![FailFeed](https://raw.githubusercontent.com/chrisliebaer/FailFeed/master/.github/assets/example1.png)

The display is especially useful for healers and tanks to understand if you are doing something wrong or if your team mates are just bad.
Sometimes it a mix of both, but you are an adult and can decide for yourself.

# Features
* Output is colored and formated to include spell icons, class color and current role
* Window is freely movable and direction and alignment of text can be customized
* Everyone will think you are a pro.
* No one knows you are using it

# Known Bugs / Wishlist
* Right now FailFeed only works within Mythic+ dungeons, and I have no plans to add support for raids or open world content. Avoiding damage in raids is much more difficult and the addon would be too spammy. Also I hate raids.
* Damage taken does not take certain absorbs or immunities into account. So damage taken should not be seen as the amount of damage that actually went through, but rather as a measure of how much damage the player was exposed to.
* I would like to eventually move away from EliteismHelper's spell database and start curating my own. This would no only allow me to release this addon under a more permissive license, but also to add load on demand support for dungeons/expansions to keep the memory requirements low.

# A word of warning
The small minded might use this addon to put blame onto others.
Mistakes in Mythic+ happen, and there are sometimes good reasons to take a hit rather than avoiding everything.
The purpose of this addon is to help with awareness and to understand why the group is taking damage.
Especially early on in a season, it might be difficult to know what damage is avoidable and what is not, especially when we consier that some dungeons are completely out of tune.
In that sense the addon will also sometimes report very hard to dodge abilities.
Not because anyone expects you to dodge them all the time, but because it helps to know when it happens.
