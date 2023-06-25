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

  def reset
    @maze = Array.new(@height) { Array.new(@width, true) }
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
    generate_maze

    @generate_button = Gosu::Image.from_text(self, 'Generate Maze', Gosu.default_font_name, 24)
    @small_button = Gosu::Image.from_text(self, 'Small', Gosu.default_font_name, 24)
    @normal_button = Gosu::Image.from_text(self, 'Normal', Gosu.default_font_name, 24)
    @large_button = Gosu::Image.from_text(self, 'Large', Gosu.default_font_name, 24)

    @button_x = (WIDTH - CONTROL_BAR_WIDTH + (CONTROL_BAR_WIDTH - BUTTON_WIDTH) / 2)
    @button_y = (HEIGHT - BUTTON_HEIGHT) / 2
    @small_button_x = (WIDTH - CONTROL_BAR_WIDTH + (CONTROL_BAR_WIDTH - BUTTON_WIDTH) / 2)
    @small_button_y = (HEIGHT - BUTTON_HEIGHT) / 2 - 60
    @normal_button_x = (WIDTH - CONTROL_BAR_WIDTH + (CONTROL_BAR_WIDTH - BUTTON_WIDTH) / 2)
    @normal_button_y = (HEIGHT - BUTTON_HEIGHT) / 2 - 120
    @large_button_x = (WIDTH - CONTROL_BAR_WIDTH + (CONTROL_BAR_WIDTH - BUTTON_WIDTH) / 2)
    @large_button_y = (HEIGHT - BUTTON_HEIGHT) / 2 - 180
  end

  def needs_cursor?
    true
  end

  def button_down(id)
    close if id == Gosu::KbEscape
    generate_maze if id == Gosu::MsLeft && mouse_over_button?
    set_maze_size('small') if id == Gosu::MsLeft && mouse_over_small_button?
    set_maze_size('normal') if id == Gosu::MsLeft && mouse_over_normal_button?
    set_maze_size('large') if id == Gosu::MsLeft && mouse_over_large_button?
  end

  def mouse_over_button?
    mouse_x > @button_x && mouse_x < @button_x + BUTTON_WIDTH &&
      mouse_y > @button_y && mouse_y < @button_y + BUTTON_HEIGHT
  end

  def mouse_over_small_button?
    mouse_x > @small_button_x && mouse_x < @small_button_x + BUTTON_WIDTH &&
      mouse_y > @small_button_y && mouse_y < @small_button_y + BUTTON_HEIGHT
  end

  def mouse_over_normal_button?
    mouse_x > @normal_button_x && mouse_x < @normal_button_x + BUTTON_WIDTH &&
      mouse_y > @normal_button_y && mouse_y < @normal_button_y + BUTTON_HEIGHT
  end

  def mouse_over_large_button?
    mouse_x > @large_button_x && mouse_x < @large_button_x + BUTTON_WIDTH &&
      mouse_y > @large_button_y && mouse_y < @large_button_y + BUTTON_HEIGHT
  end

  def draw
    draw_control_bar
    draw_button
    draw_small_button
    draw_normal_button
    draw_large_button

    block_size = [WIDTH / @maze[0].size, HEIGHT / @maze.size].min

    @maze.each_with_index do |row, y|
      row.each_with_index do |cell, x|
        color = cell == 'S' ? Gosu::Color::RED : (cell == 'D' ? Gosu::Color::BLUE : (cell ? Gosu::Color::BLACK : Gosu::Color::WHITE))
        draw_quad(x * block_size, y * block_size, color, (x + 1) * block_size, y * block_size, color,
                  (x + 1) * block_size, (y + 1) * block_size, color, x * block_size, (y + 1) * block_size, color)
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

  def draw_small_button
    @small_button.draw(@small_button_x, @small_button_y, 0)
  end

  def draw_normal_button
    @normal_button.draw(@normal_button_x, @normal_button_y, 0)
  end

  def draw_large_button
    @large_button.draw(@large_button_x, @large_button_y, 0)
  end

  def generate_maze
    @maze_generator.reset
    @maze_generator.generate
    @maze = @maze_generator.to_s.split("\n").map { |row| row.chars.map { |c| c == '█' ? false : c } }

    free_spaces = find_free_spaces
    start_point, destination_point = random_points(free_spaces)

    # Set starting point (red)
    @maze[start_point[1]][start_point[0]] = 'S'

    # Set destination point (blue)
    @maze[destination_point[1]][destination_point[0]] = 'D'
  end

  def set_maze_size(size)
    case size
    when 'small'
      @maze_generator = MazeGenerator.new((WIDTH - CONTROL_BAR_WIDTH) / 20, HEIGHT / 20)
    when 'normal'
      @maze_generator = MazeGenerator.new((WIDTH - CONTROL_BAR_WIDTH) / 10, HEIGHT / 10)
    when 'large'
      @maze_generator = MazeGenerator.new((WIDTH - CONTROL_BAR_WIDTH) / 5, HEIGHT / 5)
    end

    generate_maze
  end

  def find_free_spaces
    free_spaces = []
    @maze.each_with_index do |row, y|
      row.each_with_index do |cell, x|
        free_spaces << [x, y] if cell == false
      end
    end
    free_spaces
  end

  def random_points(free_spaces)
    start_point = free_spaces.sample
    free_spaces.delete(start_point)
    destination_point = free_spaces.sample
    [start_point, destination_point]
  end
end

MazeWindow.new.show
