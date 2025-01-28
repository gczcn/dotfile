import curses

def main(stdscr):
    stdscr.clear()
    stdscr.addstr("stnaeisntieonaisonetis")
    stdscr.refresh()
    stdscr.getch()

curses.wrapper(main)
