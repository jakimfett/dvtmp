/* valid curses attributes are listed below they can be ORed
 *
 * A_NORMAL        Normal display (no highlight)
 * A_STANDOUT      Best highlighting mode of the terminal.
 * A_UNDERLINE     Underlining
 * A_REVERSE       Reverse video
 * A_BLINK         Blinking
 * A_DIM           Half bright
 * A_BOLD          Extra bright or bold
 * A_PROTECT       Protected mode
 * A_INVIS         Invisible or blank mode
 */

enum {
	DEFAULT,
	BLUE,
};

static Color colors[] = {
	[DEFAULT] = { .fg = -1,         .bg = -1, .fg256 = -1, .bg256 = -1, },
	[BLUE]    = { .fg = COLOR_BLUE, .bg = -1, .fg256 = 68, .bg256 = -1, },
};

#define COLOR(c)        COLOR_PAIR(colors[c].pair)
/* curses attributes for the currently focused window */
#define SELECTED_ATTR   (COLOR(BLUE) | A_NORMAL)
/* curses attributes for normal (not selected) windows */
#define NORMAL_ATTR     (COLOR(DEFAULT) | A_NORMAL)
/* curses attributes for a window with pending urgent flag */
#define URGENT_ATTR     NORMAL_ATTR
/* curses attributes for the status bar */
#define BAR_ATTR        (COLOR(BLUE) | A_NORMAL)
/* characters for beginning and end of status bar message */
#define BAR_BEGIN       '['
#define BAR_END         ']'
/* status bar (command line option -s) position */
#define BAR_POS         BAR_TOP /* BAR_BOTTOM, BAR_OFF */
/* whether status bar should be hidden if only one client exists */
#define BAR_AUTOHIDE    true
/* master width factor [0.1 .. 0.9] */
#define MFACT 0.5
/* number of clients in master area */
#define NMASTER 1
/* scroll back buffer size in lines */
#define SCROLL_HISTORY 500
/* printf format string for the tag in the status bar */
#define TAG_SYMBOL   "[%s]"
/* curses attributes for the currently selected tags */
#define TAG_SEL      (COLOR(BLUE) | A_BOLD)
/* curses attributes for not selected tags which contain no windows */
#define TAG_NORMAL   (COLOR(DEFAULT) | A_NORMAL)
/* curses attributes for not selected tags which contain windows */
#define TAG_OCCUPIED (COLOR(BLUE) | A_NORMAL)
/* curses attributes for not selected tags which with urgent windows */
#define TAG_URGENT (COLOR(BLUE) | A_NORMAL | A_BLINK)

const char tags[][8] = { "1", "2", "3", "4", "5" };

#include "tile.c"
#include "grid.c"
#include "bstack.c"
#include "fullscreen.c"

/* by default the first layout entry is used */
static Layout layouts[] = {
	{ "[]=", tile },
	{ "+++", grid },
	{ "TTT", bstack },
	{ "[ ]", fullscreen },
};

#define MOD  CTRL('g')
#define CREATE  'c'
#define CREATE_CWD  'C'
#define KILL_CLIENT  'x'
#define FOCUS_NEXT  'j'
#define FOCUS_NEXT_MIN  'J'
#define FOCUS_PREV_MIN  'K'
#define FOCUS_PREV  'k'
#define TILE_VERTICAL  'f'
#define TILE_GRID  'g'
#define TILE_BOTTOM  'b'
#define MAX_WINDOW  'm'
#define TOGGLE_LAYOUTS  ' '
#define INCR_WINDOWS  'i'
#define DECR_WINDOWS  'd'
#define MASTER_DECR  'h'
#define MASTER_INCR  'l'
#define TOGGLE_MIN  '.'
#define SHOW_HIDE_STATUS  's'
#define TOGGLE_STATUS_LOC  'S'
#define TOGGLE_MOUSE  'M'
#define ZOOM1  '\n'
#define ZOOM2  '\r'
#define FOCUS_PREV_WINDOW  '\t'
#define MULTIPLEX_TOGGLE  'a'
#define REDRAW_CTL_L  CTRL('L')
#define REDRAW_R  'r'
#define COPY_MODE1  'e'
#define COPY_MODE2  '/'
#define PASTE  'p'
#define VIEW  'v'

#define TAGKEYS(KEY,TAG) \
	{ { MOD, 'v', KEY,     }, { view,           { tags[TAG] }               } }, \
	{ { MOD, 't', KEY,     }, { tag,            { tags[TAG] }               } }, \
	{ { MOD, 'V', KEY,     }, { toggleview,     { tags[TAG] }               } }, \
	{ { MOD, 'T', KEY,     }, { toggletag,      { tags[TAG] }               } },

/* you can at most specifiy MAX_ARGS (3) number of arguments */
static KeyBinding bindings[] = {
	{ { MOD, CREATE,          }, { create,         { NULL }                    } },
	{ { MOD, CREATE_CWD,          }, { create,         { NULL, NULL, "$CWD" }      } },
	{ { MOD, KILL_CLIENT, KILL_CLIENT,     }, { killclient,     { NULL }                    } },
	{ { MOD, FOCUS_NEXT,          }, { focusnext,      { NULL }                    } },
	{ { MOD, FOCUS_NEXT_MIN,          }, { focusnextnm,    { NULL }                    } },
	{ { MOD, FOCUS_PREV_MIN,          }, { focusprevnm,    { NULL }                    } },
	{ { MOD, FOCUS_PREV,          }, { focusprev,      { NULL }                    } },
	{ { MOD, TILE_VERTICAL,          }, { setlayout,      { "[]=" }                   } },
	{ { MOD, TILE_GRID,          }, { setlayout,      { "+++" }                   } },
	{ { MOD, TILE_BOTTOM,          }, { setlayout,      { "TTT" }                   } },
	{ { MOD, MAX_WINDOW,          }, { setlayout,      { "[ ]" }                   } },
	{ { MOD, TOGGLE_LAYOUTS,          }, { setlayout,      { NULL }                    } },
	{ { MOD, INCR_WINDOWS,          }, { incnmaster,     { "+1" }                    } },
	{ { MOD, DECR_WINDOWS,          }, { incnmaster,     { "-1" }                    } },
	{ { MOD, MASTER_DECR,          }, { setmfact,       { "-0.05" }                 } },
	{ { MOD, MASTER_INCR,          }, { setmfact,       { "+0.05" }                 } },
	{ { MOD, TOGGLE_MIN,          }, { toggleminimize, { NULL }                    } },
	{ { MOD, SHOW_HIDE_STATUS,          }, { togglebar,      { NULL }                    } },
	{ { MOD, TOGGLE_STATUS_LOC,          }, { togglebarpos,   { NULL }                    } },
	{ { MOD, TOGGLE_MOUSE,          }, { togglemouse,    { NULL }                    } },
	{ { MOD, ZOOM1,         }, { zoom ,          { NULL }                    } },
	{ { MOD, ZOOM2,         }, { zoom ,          { NULL }                    } },
	{ { MOD, '1',          }, { focusn,         { "1" }                     } },
	{ { MOD, '2',          }, { focusn,         { "2" }                     } },
	{ { MOD, '3',          }, { focusn,         { "3" }                     } },
	{ { MOD, '4',          }, { focusn,         { "4" }                     } },
	{ { MOD, '5',          }, { focusn,         { "5" }                     } },
	{ { MOD, '6',          }, { focusn,         { "6" }                     } },
	{ { MOD, '7',          }, { focusn,         { "7" }                     } },
	{ { MOD, '8',          }, { focusn,         { "8" }                     } },
	{ { MOD, '9',          }, { focusn,         { "9" }                     } },
	{ { MOD, FOCUS_PREV_WINDOW,         }, { focuslast,      { NULL }                    } },
	{ { MOD, 'q', 'q',     }, { quit,           { NULL }                    } },
	{ { MOD, MULTIPLEX_TOGGLE,          }, { togglerunall,   { NULL }                    } },
	{ { MOD, REDRAW_CTL_L,    }, { redraw,         { NULL }                    } },
	{ { MOD, REDRAW_R,          }, { redraw,         { NULL }                    } },
	{ { MOD, COPY_MODE1,          }, { copymode,       { NULL }                    } },
	{ { MOD, COPY_MODE2,          }, { copymode,       { "/" }                     } },
	{ { MOD, PASTE,          }, { paste,          { NULL }                    } },
	{ { MOD, KEY_PPAGE,    }, { scrollback,     { "-1" }                    } },
	{ { MOD, KEY_NPAGE,    }, { scrollback,     { "1"  }                    } },
	{ { MOD, '?',          }, { create,         { "man dvtmp", "dvtmp help" } } },
	{ { MOD, MOD,          }, { send,           { (const char []){MOD, 0} } } },
	{ { KEY_SPREVIOUS,     }, { scrollback,     { "-1" }                    } },
	{ { KEY_SNEXT,         }, { scrollback,     { "1"  }                    } },
	{ { MOD, '0',          }, { view,           { NULL }                    } },
	{ { MOD, KEY_F(1),     }, { view,           { tags[0] }                 } },
	{ { MOD, KEY_F(2),     }, { view,           { tags[1] }                 } },
	{ { MOD, KEY_F(3),     }, { view,           { tags[2] }                 } },
	{ { MOD, KEY_F(4),     }, { view,           { tags[3] }                 } },
	{ { MOD, KEY_F(5),     }, { view,           { tags[4] }                 } },
	{ { MOD, VIEW, '0'      }, { view,           { NULL }                    } },
	{ { MOD, VIEW, '\t',    }, { viewprevtag,    { NULL }                    } },
	{ { MOD, 't', '0'      }, { tag,            { NULL }                    } },
	TAGKEYS( '1',                              0)
	TAGKEYS( '2',                              1)
	TAGKEYS( '3',                              2)
	TAGKEYS( '4',                              3)
	TAGKEYS( '5',                              4)
};

static const ColorRule colorrules[] = {
	{ "", A_NORMAL, &colors[DEFAULT] }, /* default */
};

/* possible values for the mouse buttons are listed below:
 *
 * BUTTON1_PRESSED          mouse button 1 down
 * BUTTON1_RELEASED         mouse button 1 up
 * BUTTON1_CLICKED          mouse button 1 clicked
 * BUTTON1_DOUBLE_CLICKED   mouse button 1 double clicked
 * BUTTON1_TRIPLE_CLICKED   mouse button 1 triple clicked
 * BUTTON2_PRESSED          mouse button 2 down
 * BUTTON2_RELEASED         mouse button 2 up
 * BUTTON2_CLICKED          mouse button 2 clicked
 * BUTTON2_DOUBLE_CLICKED   mouse button 2 double clicked
 * BUTTON2_TRIPLE_CLICKED   mouse button 2 triple clicked
 * BUTTON3_PRESSED          mouse button 3 down
 * BUTTON3_RELEASED         mouse button 3 up
 * BUTTON3_CLICKED          mouse button 3 clicked
 * BUTTON3_DOUBLE_CLICKED   mouse button 3 double clicked
 * BUTTON3_TRIPLE_CLICKED   mouse button 3 triple clicked
 * BUTTON4_PRESSED          mouse button 4 down
 * BUTTON4_RELEASED         mouse button 4 up
 * BUTTON4_CLICKED          mouse button 4 clicked
 * BUTTON4_DOUBLE_CLICKED   mouse button 4 double clicked
 * BUTTON4_TRIPLE_CLICKED   mouse button 4 triple clicked
 * BUTTON_SHIFT             shift was down during button state change
 * BUTTON_CTRL              control was down during button state change
 * BUTTON_ALT               alt was down during button state change
 * ALL_MOUSE_EVENTS         report all button state changes
 * REPORT_MOUSE_POSITION    report mouse movement
 */

#ifdef NCURSES_MOUSE_VERSION
# define CONFIG_MOUSE /* compile in mouse support if we build against ncurses */
#endif

#define ENABLE_MOUSE true /* whether to enable mouse events by default */

#ifdef CONFIG_MOUSE
static Button buttons[] = {
	{ BUTTON1_CLICKED,        { mouse_focus,      { NULL  } } },
	{ BUTTON1_DOUBLE_CLICKED, { mouse_fullscreen, { "[ ]" } } },
	{ BUTTON2_CLICKED,        { mouse_zoom,       { NULL  } } },
	{ BUTTON3_CLICKED,        { mouse_minimize,   { NULL  } } },
};
#endif /* CONFIG_MOUSE */

static Cmd commands[] = {
	{ "create", { create,	{ NULL } } },
};

/* gets executed when dvtmp is started */
static Action actions[] = {
	{ create, { NULL } },
};

static char const * const keytable[] = {
	/* add your custom key escape sequences */
};

/* editor to use for copy mode. If neither of DVTP_EDITOR, EDITOR and PAGER is
 * set the first entry is chosen. Otherwise the array is consulted for supported
 * options. A %d in argv is replaced by the line number at which the file should
 * be opened. If filter is true the editor is expected to work even if stdout is
 * redirected (i.e. not a terminal). If color is true then color escape sequences
 * are generated in the output.
 */
static Editor editors[] = {
	{ .name = "vis",         .argv = { "vis", "+%d", "-", NULL   }, .filter = true,  .color = false },
	{ .name = "sandy",       .argv = { "sandy", "-d", "-", NULL  }, .filter = true,  .color = false },
	{ .name = "dvtmp-editor", .argv = { "dvtmp-editor", "-", NULL  }, .filter = true,  .color = false },
	{ .name = "vim",         .argv = { "vim", "+%d", "-", NULL   }, .filter = false, .color = false },
	{ .name = "less",        .argv = { "less", "-R", "+%d", NULL }, .filter = false, .color = true  },
	{ .name = "more",        .argv = { "more", "+%d", NULL       }, .filter = false, .color = false },
};
