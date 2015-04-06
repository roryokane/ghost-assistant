# Ghost Assistant

A program that can perfectly play the word game [GHOST](http://en.wikipedia.org/wiki/Ghost_%28game%29).

Sample run:

    $ bundle exec ruby lib/ghost_assistant.rb
    GHOST word game assistant
    How many people are playing? (default 2)
    2
    What letters have been said so far?
    lo
    935 words start with “lo”; random 10:
    loam
    loamed
    loamier
    loamiest
    loaming
    loamless
    loams
    loamy
    loan
    loanable
    302 suitable words found; random 10:
    locoweed
    loculate
    locule
    loculi
    locums
    locust
    locustae
    locustal
    locution
    locutories
    Suggested letter to say: L (forming “lol”), with score 1
    A word starting with “lol”: loll

## Installation

Prerequisites:

* Ruby
* Bundler (`gem install bundler`)

Installation:

1. download this program, for instance with `git clone https://github.com/roryokane/ghost-assistant.git`
2. `bundle install`
