# Where I Am Now
I am writing this to document my journey into reverse engineering. It's currently 27.04.2024. My experience in this field at this point is:
* I've watched the majority of LiveOverflow's YouTube series on binary exploitation.
* I've completed the majority of Phoenix on https://exploit.education, and some of Nebula.
* I've read parts of the book "Hacking: the art of exploitation", which is mostly the same content as the LiveOverflow playlist.

Before all of this, I have read the main parts of a book on operating systems, a book on networking,  and one on computer architecture. I also work in the field of IT as a platform developer. I've programmed a lot throughout the years as a hobby, but I haven't been consistent with it. Mainly just during vacations when I've had the time and motivation. Most of the programming I've done as a hobby has been in game dev. I should also mention that I have spent countless hours on youtube and google, picking up bits and pieces on all things tech. 

# My First Project
I really enjoy low level stuff, but so far, I haven't found a project to work on and develop serious skills. I've mostly read theory and played around a bit in gdb to solve the exploit.education levels etc. Finding a good first project is not easy. I want it be challenging, but not so challenging that I feel completely overwhelmed and feel like I can't progress. I also want a project that hasn't been done before, so it won't feel a waste of time reinventing the wheel. However, if it's something completely new, it will be very hard when to get going and when I'm stuck.

I've decided to try messing around with old GameBoy ROMs as my first project. I love pokemon, and although it's been done before, I will try the following strategy:
* Read up on how to set up a reverse engineering environment, i.e get set up with emulator, debugger etc.
* Read up on the process of how to reverse a few simple features in pokemon and how to patch the ROM.
* When I have a basic understanding: try to go on my own and find some limitation in the game that I want to reverse and circumvent. For example: create a patch that allow me to pick up all 3 starter pokemon.
* There is probably enormous amounts of information on how to reverse probably every single feature in old pokemon games, but I will try my best to stay away from this information. I will read enough to get going, but I want to discover as much as possible for myself.

INSERT POKEMON GAME

The first thing I will do is to watch this video on YouTube by "stacksmashing", called "How to reverse engineer & patch a Game Boy ROM": https://www.youtube.com/watch?v=dQLp5i8oS3Y


# The GameBoy Advance
According to Wikipedia, the CPU is ARM7TDMI (**ARM7** + 16 bit **T**humb + JTAG **D**ebug + fast **M**ultiplier + enhanced **I**CE), and it implements the [[ARMv4]] instruction set. I should begin familiarizing myself with this ISA.

Keep in mind that the "7" in ARM7TDMI does not refer to the ARM ISA version. ARMv7 is a much later version of the ARM architecture. See [[ARM7TDMI vs ARMv4 vs ARMv7]] for further explanation.