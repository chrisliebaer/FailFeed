![Stading in Fire: Bad](https://raw.githubusercontent.com/chrisliebaer/FailFeed/master/.github/assets/badge/badge_fire.svg)

FailFeed is a World of Warcraft addon that displays a "kill"-feed of the stuff your boosted monkey team mates are taking avoidable damage from.
Similar to [ElitismHelper](https://github.com/amki/ElitismHelper) but just for you without spaming the chat.
In fact most of the internal spell database is taken from ElitismHelper.

![FailFeed](https://raw.githubusercontent.com/chrisliebaer/FailFeed/master/.github/assets/example1.png)

The display is especially useful for healers and tanks to understand if you are doing something wrong or if your team mates are just bad.
Sometimes it a mix of both, but you are an adult and can decide for yourself.

# Features
* Output is colored and formated to include spell icons, class color and current role
* Window is freely movable and direction and alignment of text can be customized
* No one knows you are using it

# Known Bugs / Wishlist
* Ideally the addon would use EliteHelper's spell database directly, but EliteHelper does not currently expose it's database
* Damage taken is calculated wrong but I could not find any documentation on how to accurately get the effective damage taken
* CI builds could be improved to include external dependencies rather than committing them to the repo and to include a version number directly from the CI pipeline
