/*
  Project: working-with-supercollider
  File: cheatsheet.scd
  Author: Leonard M Reidy
  Source: https://github.com/leonardreidy/working-with-supercollider/blob/master/cheatsheet.scd
  Docs: [
    http://supercollider.sourceforge.net/wiki/index.php/User_FAQ,
    https://doc.sccode.org/Overviews/Documents.html
  ]
  Description: This file contains widely useful code snippets for common tasks. At present,
  almost all of the code below was selected from Thor Magnusson's Scoring Sound. As time
  goes on I hope to add more and more to this file as I encounter it. If you want to see
  more of Thor Magnusson's Scoring Sound you can find it at:

    https://leanpub.com/ScoringSound

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

  // Functions are defined most precisely in the documentation as follows:
  // "A Function is an expression which defines operations to be performed
  // when it is sent the 'value' message."
  // As defined, Functions in Supercollider are in fact objects, since they
  // respond, as objects do, to messages, importantly, the 'value' message.
  // Sending the 'value' message to a Function is what executes the function.
  // Functions are defined between braces, and the value of the last line
  // evaluated is returned. See examples below:
(
    // Declare two variables, one to store a function, the other to store
    // the results of executing that function
    var makeADict, aDict;

    // An example of a function that returns a Dictionary
    makeADict = {
        var firstVal, secondVal, thirdVal;
        firstVal = 0;
        secondVal = 1;
        thirdVal = 2;
        // This is the data structure that makeADict will return, a
        // so-called Dictionary, which is an associative collection
        // mapping keys to values.
        (a: firstVal, b: secondVal, c: thirdVal);
    };

    // Call the example function and assign the result to a variable
    aDict = makeADict.value;

    // Print the contents of the variable to the Post Window
    aDict.postln;

    // Print the value associated with the a key of the aDict dictionary
    aDict.a.postln;

    // Print the value associated with the b key of the aDict dictionary
    aDict.b.postln;

    // Print the value associated with the c key of the aDict dictionary
    aDict.c.postln;

)

(
    // The previous example with parameters instead of hardwired values
    var makeADict, aDict;

    makeADict = {
        arg firstVal, secondVal, thirdVal;
        (a: firstVal, b: secondVal, c: thirdVal);
    };

    aDict = makeADict.value(0,1,2);
    aDict.postln;
    aDict.a.postln;
    aDict.b.postln;
    aDict.c.postln;
)

(
    // The previous example with syntactic sugar
    var makeADict, aDict;

    makeADict = { | firstVal, secondVal, thirdVal | (a: firstVal, b: secondVal, c: thirdVal); };

    aDict = makeADict.value(0,1,2);
    aDict.postln;
    aDict.a.postln;
    aDict.b.postln;
    aDict.c.postln;
)

(
  // Declare a variable to store a function
  var c, d;

  // Define a function to convert a frequency into the corresponding midi value
  // and assign to the variable c
  // |freq| is syntactic sugar for the function's parameter. It means, in
  // essence, treat freq as an input to the function. If you are not familiar with the phrase
  // 'syntactic sugar,' it simply means an alternate way of writing some piece of code to make
  // it easier to read or understand. Some languages provide syntactic sugar to make the
  // developer experience a little better; Supercollider's sclang is one such language
  c = { |freq| 69 + (12 * log(220/freq) / log(2)); };

  // Here's how the function definition would look without the syntactic sugar
  d = { arg freq; 69 + (12 * log(220/freq) / log(2)); };

  // Execute (call) the function
  c.value(440);
  d.value(440);
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
   var trigger = LFNoise0.ar(1)>0;
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

// Quit server
s.quit;

// Raise the server GUI widget
// Note that it responds to many useful keyboard shortcuts
// Make sure the widget is in focus and click the relevant
// key. Here are some useful functions and the corresponding
// keyboard shortcut:
//
//   i/o levels [i]
//   graphical view of node tree [p]
//   scope window [s]
//   freqscope [f]
//   toggle dumping of OSC messages to post window [d]
//   toggle mute [m]
//
// Raise the server widget:
s.makeGui;

// Get average CPU load
s.avgCPU;

// Free all synths
s.freeAll;

// Break glass in case of zombie processes or other emergencies
Server.killAll;

/* -------------------------------------------------------------------------------------- */
/* [PLOTTING SCOPING TRACING] Plotting, Scoping, Tracing                                  */
/* ---------------------------------------------------------------------------------------*/
(
  // Plot multiple SinOscs
  {[SinOsc.ar(440), SinOsc.ar(440), SinOsc.ar(440)+SinOsc.ar(440)]}.plot;
)

(
  // As above, but more concise
  {a = SinOsc.ar(440, 0, 0.5); [a, a, a+a]}.plot;
)

(
    // Scope in time domain
    s.scope;

    // Scope in frequency domain
    s.freqscope;
)

(
  // Tracing is most useful for observing streams, patterns and the like in
  // real time. Here is an example:
  SynthDef.new(\sine, {
      arg freq=440, attack=0.005, release=0.3, amp=1, pan=0;
      var sig, env;
      sig = SinOsc.ar(freq);
      env = EnvGen.kr(Env.new([0,1,0],[attack,release],[1,-1]),doneAction:2);
      sig = Pan2.ar(sig, pan, amp);
      Out.ar(0, sig);
  }).add;
)

(
  p = Pbind(
	\instrument, \sine,
	\dur, Pseq([0.6,0.15,0.15],inf).trace;
  ).play;
)

/* -------------------------------------------------------------------------------------- */
/* [PATTERNS SEQUENCING] Patterns and sequencing                                          */
/* -------------------------------------------------------------------------------------- */

// Stepper
(
  {SinOsc.ar( Stepper.kr(Impulse.kr(10), 0, 4, 16, 1) * 100, 0, 0.2)}.play;
)

(
  // Same code, but in Stereo - note !2 before the closing brace
  {SinOsc.ar( Stepper.kr(Impulse.kr(10), 0, 4, 16, 1) * 100, 0, 0.2) !2}.play;
)

(
  // Stepper with polling - see post window
  {SinOsc.ar(Stepper.kr(Impulse.kr(6), 0, 5, 15, -3).poll(6, "stepper") * 80, 0, 0.2)}.play;
)

(
  {SinOsc.ar(Lag.kr(Stepper.kr(Impulse.kr(6), 0, 5, 25, -4) * 90, 6.reciprocal), 0, 0.2)}.play;
)

// Select
(
  {
	var scale, cycle;
	// scale = Array.fill(12,{ arg i; 60 + i }).midicps;
	scale = [60, 61, 63, 64, 65, 67, 68, 69, 70].midicps; // we fill an array with a scale
	cycle = scale.size / 2;
	SinOsc.ar(Select.kr( LFSaw.kr(0.4, 1, cycle, cycle), scale ));
  }.play;
)


/* -------------------------------------------------------------------------------------- */
/* [MISC] Miscellaneous                                                                   */
/* ---------------------------------------------------------------------------------------*/
(
  // Test the impact of relatively large scale creation on your machine
  // we add 500 oscillators together and the CPU is around 20% on a low end machine
  // Intel I3 @ 2GHz
  {({SinOsc.ar(4444.4.rand, 0, 0.005)}!500).sum}.play;
)

/* -------------------------------------------------------------------------------------- */
/* [INTROSPECTION] Introspection                                                          */
/* ---------------------------------------------------------------------------------------*/
(
  // Observe all OSC messages sent to server
  s.dumpOSC(1);

  // Introspect the interface of the Function
  Function.dumpInterface;
)
