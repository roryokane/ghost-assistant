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

## Status

[![Project Status: Inactive – The project has reached a stable, usable state but is actively developed only infrequently; support/maintenance will be provided as time allows.](http://www.repostatus.org/badges/0.1.0/inactive.svg)](http://www.repostatus.org/#inactive)

This program doesn’t actually play perfectly yet – I know that its heuristics can be improved. But it’s still good enough to have beaten every human I have ever tried it against.

## Installation

Prerequisites:

* Ruby
* Bundler (`gem install bundler`)

Installation:

1. download this program, for instance with `git clone https://github.com/roryokane/ghost-assistant.git`
2. `bundle install`
