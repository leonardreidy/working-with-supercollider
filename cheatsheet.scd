/*
  Project: working-with-supercollider
  File: cheatsheet.scd
  Author: Leonard M Reidy
  Source:
  Docs: [ http://supercollider.sourceforge.net/wiki/index.php/User_FAQ ]
  Description: This file contains widely useful code snippets for common tasks

  General Notes

  To Execute: Ctrl + Enter (Cmd + Enter on MacOS)
  To hush: Ctrl + . (Cmd + . on MacOS)

*/

/* -------------------------------------------------------------------------------------- */
/* [THE POST WINDOW] Actions for the post window, useful for debugging                    */
/* ---------------------------------------------------------------------------------------*/
(
  // Write "Hello World" to Post Window
  "Hello World".post;
  // Write 'contents' of s object to Post Window (s is reserved for server)
  s.post;
)

(
  // Write "Hello World" to Post Window followed by line break
  "Hello World".postln;
  // Write 'contents' of s object to Post Window followed by line break
  s.post;
)

(
  // Add the given sentence with interpolation and formatting:
  // interpolate values 1111, 9999 in string where % occurs and
  // add a new line where \n occurs
  "the first value is %, and the second one is % \n".postf(1111, 9999);
)

(

  // postln is lazy, Post is verbose
  // Compare (scroll all the way right in the Post Window to examine)
  Array.fill(1000, {100.rand}).postln;
  Post << Array.fill(1000, { 100.rand });
)

/* -------------------------------------------------------------------------------------- */
/* [KEYBOARD SHORTCUTS] Keyboard shortcuts for common actions                             */
/* ---------------------------------------------------------------------------------------*/

  // Use Ctrl + D or Cmd + D to automatically search the Supercollider docs (top right) for
  // any given keyword such as SinOsc or Array

  // Use Ctrl + . to hush all sound

  // Use Ctrl + Shift + P to clear the Post Window

/* -------------------------------------------------------------------------------------- */
/* [VARIABLES] Variables in Supercollider                                                 */
/* ---------------------------------------------------------------------------------------*/

  // Variables are dynamically typed in Supercollider.
  // There are, broadly speaking three types:
  //   - globals         (a to z, s reserved for server)
  //   - environmentals  (start with ~)
  //   - function scoped (declared inside a function definition with the var keyword)

/* -------------------------------------------------------------------------------------- */
/* [FUNCTIONS] Functions in Supercollider                                                 */
/* ---------------------------------------------------------------------------------------*/

  // Functions are defined between braces, and the value of the last line evaluated is returned
  // Functions are executed (called) with the function name and the value method as in the
  // examples below:

(
  // Declare a variable to store a function
  var c, d;
  c = ();
  d = ();
  // Define a function to convert a frequency into the corresponding midi value
  // and assign to the variable c
  // |freq| is syntactic sugar for the function's parameter. It means, in
  // essence, treat freq as an input to the function. If you are not familiar with the phrase
  // 'syntactic sugar,' it simply means an alternate way of writing some piece of code to make
  // it easier to read or understand. Some languages provide syntactic sugar to make the
  // developer experience a little better; Supercollider's sclang is one such language
  c.freqToMidi = { |freq| 69 + (12 * log(220/freq) / log(2)); };

  // Here's how the function definition would look without the syntactic sugar
  d.freqToMidi = { arg freq; 69 + (12 * log(220/freq) / log(2)); };

  // Execute (call) the function
  c.freqToMidi.value(440);
  d.freqToMidi.value(440);
)

/* -------------------------------------------------------------------------------------- */
/* [PHYSICAL MODELLING] Useful physical modelling examples                                */
/* ---------------------------------------------------------------------------------------*/

// BALL
(
  // TBall arguments are trigger, gravity, damp and friction
  {TBall.ar(Impulse.ar(0), 0.1, 0.2, 0.01)*20}.play;
)

(
  {TBall.ar(Impulse.ar(0), 0.1, 0.1, 0.001)*20}.play;
)

(
  {TBall.ar(Impulse.ar(0), 0.1, 0.2, 0.1)*20}.play;
)

(
  {Ringz.ar(TBall.ar(Impulse.ar(0), 0.09, 0.1, 0.01)*20, 3000, 0.08)}.play;
)

(
  {Decay.ar(TBall.ar(Impulse.ar(0), 0.09, 0.1, 0.01)*20, 1)}.play;
)

// A more complex example using a second order filter section
(
  var gravity = 0.8;
  var damp = 0.2;
  var friction = 0.02;
  var multiplier = 20;

  var surface = { |x| Impulse.ar(1, x*0.1*x) };
  var tballer = {
	arg x, gravity, damp, friction;
	TBall.ar(surface.value(x), gravity, damp, friction);
  };

  // Note, SOS is a second order filter. Filter coefficients are given
  // directly rather than calculated. The formula associated with the filter is:
  // out(i) = (a0 * in(i)) + (a1 * in(i-1)) + (a2 * in(i-2)) + (b1 * out(i-1)) + (b2 * out(i-2))
  // SOS params are in, a0, a1, a2, b1, b2, mul, add
  {
	({ |x| SOS.ar(
	    tballer.value(x, gravity, damp, friction)* multiplier, // in
		0.6,                                                   // a0
		0.0,                                                   // a1
		0.0,                                                   // a2
		rrand(1.992, 1.99),                                    // b1
		-0.9982                                                // b2
	  )
	}!6).sum
  }.play;
)

// SPRING
(
 {
   var trigger =LFNoise0.ar(1)>0;
   var signal = SinOsc.ar(Spring.ar(trigger,1,4e-06)*1220);
   var env = EnvGen.kr(Env.perc(0.001,5),trigger);
   Out.ar(0, Pan2.ar(signal * env, 0));
 }.play;
)

(
  play{{x=LFNoise0.ar(1)>0;SinOsc.ar(Spring.ar(x, 4,3e-05)*(70.rand+190)+(30.rand+90))*EnvGen.kr(Env.perc(0.001,5),x)}!2};
)

// FRICTION
(
  {Friction.ar(Ringz.ar(Impulse.ar(1), [400, 412]), 0.0002, 0.2, 2, 2.697)}.play;
)

(
  {Friction.ar(Klank.ar(`[[400, 412, 340]], Impulse.ar(1)), 0.0002, 0.2, 2, 2.697)!2}.play;
)

/* -------------------------------------------------------------------------------------- */
/* [IMPLEMENTATION] Look up implementation of a given keyword, class, function, etc       */
/* ---------------------------------------------------------------------------------------*/
// Click on space next to a keyword like SinOsc or Array and press:
// (Ctrl + i or Cmd + i on MacOSX)

/* -------------------------------------------------------------------------------------- */
/* [SERVER] Common server actions                                                         */
/* ---------------------------------------------------------------------------------------*/

// Boot server
s.boot;

// Reboot server
s.reboot;

// Get average CPU load
s.avgCPU;

/* -------------------------------------------------------------------------------------- */
/* [PLOTTING SCOPING] Plotting and Scoping                                                */
/* ---------------------------------------------------------------------------------------*/
(
  {[SinOsc.ar(440), SinOsc.ar(440), SinOsc.ar(440)+SinOsc.ar(440)]}.plot;
)

(
  {a = SinOsc.ar(440, 0, 0.5); [a, a, a+a]}.plot;
)


/* -------------------------------------------------------------------------------------- */
/* [MISC] Miscellaneous                                                                   */
/* ---------------------------------------------------------------------------------------*/
  // Test the impact of relatively large scale creation on your machine
(
  // we add 500 oscillators together and the CPU is around 20% on a low end machine
  // Intel I3 @ 2GHz
  {({SinOsc.ar(4444.4.rand, 0, 0.005)}!500).sum}.play;
)
