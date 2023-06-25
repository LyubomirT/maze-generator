# Maze Generator

This project is a Maze Generator implemented in Gosu. It uses the Recursive Backtracking algorithm to generate a maze.

## How it Works

The `MazeGenerator` class implements the maze generation algorithm. It takes the width and height of the maze as input and creates a maze grid. The `generate` method generates the maze using the Recursive Backtracking algorithm. It maintains a stack of visited cells and repeatedly selects a random neighboring cell until all cells have been visited.

The `get_neighbors` method returns a list of unvisited neighboring cells for a given cell. The `remove_wall` method removes the wall between two cells, creating a passage in the maze.

The `to_s` method converts the maze grid into a string representation, where '█' represents walls and ' ' represents passages.

The `reset` method resets the maze to its initial state.

The `MazeWindow` class represents the game window using the Gosu library. It initializes the window and sets up the maze generator. It handles user input, including generating a new maze and changing the maze size. The `draw` method is responsible for rendering the maze on the screen.

## Getting Started

To run the Maze Generator, you need to have Gosu installed. You can install it using the following command:

```
gem install gosu
```

Once you have Gosu installed, you can create an instance of the `MazeWindow` class and call the `show` method to start the game.

```ruby
MazeWindow.new.show
```

## Controls

- Use the left mouse button to generate a new maze.
- Click the "Small" button to set the maze size to small.
- Click the "Normal" button to set the maze size to normal.
- Click the "Large" button to set the maze size to large.
- Press the Esc key to exit the game.

Note: The maze size affects the complexity and size of the generated maze.

## Acknowledgements

This project was created to learn Gosu and is based on the Recursive Backtracking algorithm for maze generation.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.