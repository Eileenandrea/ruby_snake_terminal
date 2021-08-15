require "curses"
include Curses 
#-generate board
#-draw snake
#-generate random food

class Snake
    attr_accessor :possition, :direction, :size, :gameover,:score,:level,:speed
    def initialize
        @possition = [[5,6],[5,7],[5,8],[5,9],[5,10]];
        @direction = "right";
        @size = @possition.length;
        @gameover = false
        @score=0
        @level=1 
        @speed= 0.2
    end
    def moveSnake
        @possition.shift
        case @direction
        when "right"
            @possition.push([head[0], head[1] +=1])
        when "down"
           @possition.push([head[0] +=1, head[1]])
        when "left"
            @possition.push([head[0], head[1] -=1])
        when "up"
             @possition.push([head[0]-=1, head[1] ])
        end
    end
    def gameOver?(maxx,maxy)
        if head[0] == 0 || head[1] == 0 || head[0] == maxy-1|| head[1] == maxx-1 || collide?
            @gameover= true
        else
            @gameover = false
        end
        @gameover
    end
    def collide?
        if @possition.slice(0,@possition.length-1).include?(head)
            return true
        else
            return false
        end
    end
    def atefood?(food)
        head == food
    end
    def increaseSize
        @possition.unshift(tail)
        @score += 1
        if @score %10 ==0
        increaseLvl()
        increaseSpeed()
        end
    end
    def increaseLvl
        @level +=1
    end
    def increaseSpeed
        @speed -= (@speed*0.2) unless @speed < 0.001
    end
    def changeDirection(direction)
        case direction
            when "right"
                if @direction == "right"
                    @direction = "down"
                elsif @direction == "left"
                     @direction = "up"
                else
                    @direction = "right"
                end
            when "left"
                if @direction == "left"
                    @direction = "down"
                elsif @direction == "right"
                     @direction = "up"
                else
                    @direction = "left"
                end
            when "up"
                if @direction == "down"
                    @direction = "down"
                else
                    @direction = "up"
                end
            when "down"
                if @direction == "up"
                    @direction = "up"
                else
                    @direction = "down"
                end
            end
    end
    private 
    def head
        @possition.last.clone
    end
    def tail
        @possition.first.clone
    end
end
def generateFood(maxCol,maxRow)
    [rand(1..(maxCol)), rand(1..(maxRow))]
end
init_screen
cbreak
noecho						
curs_set(0)			
@snake = Snake.new()
@food = generateFood(lines-10,cols-2)

begin
  win1 = Curses::Window.new(5, Curses.cols, 0, 0)
  win1.box("|", "-")
  win1.setpos(win1.maxy/2, win1.maxx/2)
  win1.addstr("snake")
  win1.refresh
  win1.keypad = true
  inputThread = Thread.new do
        while true
            input = win1.getch
            if input == Curses::Key::RIGHT then
                @snake.changeDirection('right')
            elsif input == Curses::Key::DOWN then
                @snake.changeDirection('down')
            elsif input == Curses::Key::LEFT then
               @snake.changeDirection('left')
            elsif input == Curses::Key::UP then
                @snake.changeDirection('up')
            else
                @snake.gameover = true
            end
            win1.refresh
        end
    end

    loop do
        window = Curses::Window.new(Curses.lines - 8, Curses.cols, 5, 0)
        window.box('|','-')
        window.setpos(0, 0)
        window.setpos(@food[0], @food[1])
        window.addstr("o")
      
        @snake.moveSnake
        if @snake.atefood?(@food)
            @snake.increaseSize
            @food = generateFood(lines-10,cols-2)
        end

        if @snake.gameOver?(window.maxx,window.maxy)
            window.clear
            window = Curses::Window.new(Curses.lines - 8, Curses.cols, 5, 0)
            window.box('|','-')
            window.setpos(5, 5)
            window.addstr("gameover")
            window.refresh
            sleep 5
                break
              close_screen
        end
        @snake.possition.each do |pos|
            window.setpos(pos[0], pos[1])
            window.addstr("█")
            window.refresh
        end
        window.clear
        sleep @snake.speed
     window2 = Curses::Window.new(3, Curses.cols,Curses.lines-3, 0)
        window2.box('|','-') 
        window2.setpos(window2.maxy/2, 5) 
        window2.addstr("Score: #{@snake.score}")
        window2.addstr("   speed: #{(1/@snake.speed).truncate(2)}fps")
        window2.addstr("   level: #{@snake.level}")
        window2.refresh 
        window.clear
        
    end

ensure
  close_screen
end