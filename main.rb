require 'gosu'

# Maze generation algorithm (Recursive Backtracking)
class MazeGenerator
  def initialize(width, height)
    @width = width
    @height = height
    @maze = Array.new(height) { Array.new(width, true) }
  end

  def generate
    stack = [[0, 0]]

    until stack.empty?
      current_x, current_y = stack.last
      @maze[current_y][current_x] = false

      neighbors = get_neighbors(current_x, current_y)

      if neighbors.empty?
        stack.pop
      else
        next_x, next_y = neighbors.sample
        remove_wall(current_x, current_y, next_x, next_y)
        stack << [next_x, next_y]
      end
    end
  end

  def get_neighbors(x, y)
    neighbors = []
    neighbors << [x - 2, y] if x >= 2 && @maze[y][x - 2]
    neighbors << [x + 2, y] if x <= @width - 3 && @maze[y][x + 2]
    neighbors << [x, y - 2] if y >= 2 && @maze[y - 2][x]
    neighbors << [x, y + 2] if y <= @height - 3 && @maze[y + 2][x]
    neighbors
  end

  def remove_wall(x1, y1, x2, y2)
    @maze[(y1 + y2) / 2][(x1 + x2) / 2] = false
  end

  def to_s
    @maze.map { |row| row.map { |cell| cell ? '█' : ' ' }.join }.join("\n")
  end
end

# Game window
class MazeWindow < Gosu::Window
  WIDTH = 800
  HEIGHT = 600
  CONTROL_BAR_WIDTH = 200
  BUTTON_WIDTH = 160
  BUTTON_HEIGHT = 40

  def initialize
    super(WIDTH, HEIGHT, false)
    self.caption = 'Maze Generator'

    @maze_generator = MazeGenerator.new((WIDTH - CONTROL_BAR_WIDTH) / 10, HEIGHT / 10)
    @maze = nil

    @generate_button = Gosu::Image.from_text(self, 'Generate Maze', Gosu.default_font_name, 24)
    @button_x = (WIDTH - CONTROL_BAR_WIDTH + (CONTROL_BAR_WIDTH - BUTTON_WIDTH) / 2)
    @button_y = (HEIGHT - BUTTON_HEIGHT) / 2
  end

  def needs_cursor?
    true
  end

  def button_down(id)
    close if id == Gosu::KbEscape
    generate_maze if id == Gosu::MsLeft && mouse_over_button?
  end

  def draw
    draw_control_bar
    draw_button

    if @maze
      maze_x = (WIDTH - CONTROL_BAR_WIDTH) / 10
      maze_y = HEIGHT / 10
      @maze.each_with_index do |row, y|
        row.each_with_index do |cell, x|
          color = cell ? Gosu::Color::BLACK : Gosu::Color::WHITE
          draw_quad(x * 10, y * 10, color, (x + 1) * 10, y * 10, color,
                    (x + 1) * 10, (y + 1) * 10, color, x * 10, (y + 1) * 10, color)
        end
      end
    end
  end

  private

  def draw_control_bar
    draw_quad(WIDTH - CONTROL_BAR_WIDTH, 0, Gosu::Color::GRAY, WIDTH, 0, Gosu::Color::GRAY,
              WIDTH - CONTROL_BAR_WIDTH, HEIGHT, Gosu::Color::GRAY, WIDTH, HEIGHT, Gosu::Color::GRAY)
  end

  def draw_button
    @generate_button.draw(@button_x, @button_y, 0)
  end

  def generate_maze
    @maze_generator.generate
    @maze = @maze_generator.to_s.split("\n").map { |row| row.chars.map { |c| c == '█' } }
  end

  def mouse_over_button?
    mouse_x > @button_x && mouse_x < @button_x + BUTTON_WIDTH &&
      mouse_y > @button_y && mouse_y < @button_y + BUTTON_HEIGHT
  end
end

MazeWindow.new.show
