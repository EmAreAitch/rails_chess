# Rails Chess Backend for QuickMate

A modern, interactive chess game built with React and Rails. You can play the game at [QuickMate](https://quickmate.vercel.app "QuickMate")

<div align="center">
  <img height="467" width="831" alt="quickmate.vercel.app" title="LOL" src="https://images2.imgbox.com/4f/43/K3SosQbF_o.png" />
</div>

## Features

* Uses action cable to for web socket connection allowing real time play
* Uses personal Chess Engine (no AI) written in Ruby
* Integrates Fairy Stockfish (Consumes 5x less memory than stockfish) for player vs bot match with multiple difficulty
* Legal move validation
* Game state management (turns, check, checkmate, etc.)
* Uses Game Manager that provides:
  * Player vs Random Player - Separate thread safe queue is used to store a pool of players connected to game and looking for a match.
  * Player vs Friend - Hash containing all the Room that player can join with Room Code and start the game
* Game Manager instance is shared with all worker processes with the help of DRuby (Distributed Ruby) allowing more lightweight and centralised flow as worker only handles request and response
* Stockfish Pool with every worker allows fast access and efficient access to stockfish&#x20;
* Overall Pretty lightweight

For Front-end features - [React Chess Features](https://github.com/EmAreAitch/react_chess#features)

## Technologies Used

* [Rails](https://github.com/rails/rails)
* [Fairy Stockfish](https://github.com/fairy-stockfish/Fairy-Stockfish)
* [Ruby](https://github.com/ruby/ruby)
* [Rails Action Cable](https://www.npmjs.com/package/@rails/actioncable)
* [Puma](https://github.com/puma/puma)
* [Redis](https://github.com/redis/redis)
* [DRb - (Distributed Ruby)](https://github.com/ruby/drb)

For Front-end technologies - [React Chess Technologies](https://github.com/EmAreAitch/react_chess#technologies-used)

## Chess Engine

* Uses Object Oriented Programming to simplify internal structure
* Heavy use of cross referencing between array and objects allows fast and efficient calculations
* Modular Logic
* Extendable
* Proper exception handling and clear error messages

## Future updates

* Disconnect Inactive player
* Chess engine ends game with draw in special draw cases
* Allows to continue previous game
* More simplified version of chess engine
* Chat with opponent
* Incorporate redis wherever it can help

## Installation and Usage

You need to setup both front-end and back-end separately

### [Front-end Repository](https://github.com/EmAreAitch/react_chess)

1. Clone the repository
2. Install dependencies via `npm install`
3. Run server with `npm run dev`
4. Build with `npm run build`

### [Back-end Repository](https://github.com/EmAreAitch/rails_chess)

1. Clone the repository
2. Install dependencies via `bundle install`
3. Run server with `rails s`
4. For production you need to remove `config/credentials.yml.enc` first and then start the server

## Contact

* EmAreAitch Email - [dev.emareaitch@gmail.com](mailto\:dev.emareaitch@gmail.com)

## License

MIT License

Copyright (c) 2024 Mohammad Rahib Hasan

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
