(
//SynthDefs used in this application

SynthDef(\piano, {
	//Piano synth based on Mda Plugin "http://sccode.org/1-5aD"
    |out = 0, freq= 440, gate= 1, vel= 80, decay= 0.8, release= 0.8, hard= 0.4, velhard= 0.8, muffle= 0.8, velmuff= 0.8, velcurve= 0.8, stereo= 0.2, tune= 0.5, random= 0.1, stretch= 0.1, sustain= 0, mul= 1, add= 0, amp = 0.5|
    var snd;
    snd = MdaPiano.ar(freq, gate, vel, decay, release, hard, velhard, muffle, velmuff, velcurve, stereo, tune, random, stretch, sustain, mul, add);
    snd = snd * EnvGen.kr(Env.asr(0, 1, 0.1), gate, doneAction: 2);
    Out.ar(out, snd * amp);
}).add;

//obtained from "https://ccrma.stanford.edu/~ruviaro/texts/A_Gentle_Introduction_To_SuperCollider.pdf" (pg 99)
SynthDef(\pluck, {arg amp = 0.1, freq = 440, decay = 5, mutedString = 0.1;
	var env, snd;
	env = Env.linen(0, decay, 0).kr(doneAction: 2);
	snd = Pluck.ar(
		in: WhiteNoise.ar(amp),
		trig: Impulse.kr(0),
		maxdelaytime: 0.1,
		delaytime: freq.reciprocal,
		decaytime: decay,
		coef: mutedString);
	Out.ar(0, [snd, snd]);
}).add;

//drum synths were created by giving prompts to GPT-3.5
SynthDef(\drum1, {
    arg out = 0, pan = 0, amp = 0.7;
    var snd;

    snd = Mix.fill(4, { |i|
        var freq = [50, 100, 200, 400].choose;
        var decay = [0.05, 0.1, 0.15, 0.2].choose;
        var env = EnvGen.kr(Env.perc(0, decay), doneAction: 2);
        WhiteNoise.ar * env * LFNoise1.kr(0.5).range(0.5, 1)
    });

    snd = Pan2.ar(snd, pan, amp);

    Out.ar(out, snd);
}).add;

SynthDef(\drum2, {
    arg out = 0, freq = 60, amp = 0.6, decay = 0.1;
    var env, snd;

    env = EnvGen.kr(Env.perc(0, decay), doneAction: 2);
    snd = WhiteNoise.ar * env;
    snd = LPF.ar(snd, freq);

    Out.ar(out, Pan2.ar(snd, 0, amp));
}).add;

)

(
//The four chord patterns are defined here. These chord progressions were heavily inspired by those in "Put Your Records On" by Corinne Bailey Rae.
~piano1 = Pbind(
	\instrument, \piano,
	\note, Pseq([
		[0, 4, 7],
		[2, 6, 9, 12],
		[5, 9, 12],
		[0, 4, 7]
	], inf)
);

~piano4 = Pbind(
	\instrument, \piano,
	\note, Pseq([
		[-3, 0, 4, 7],
		[-4, -1, 2, 4],
		[-3, 0, 4, 7],
		// [2, 6, 9, 12, 16],
		[5, 9, 12, 16],
		[5, 8, 12, 16]
	], inf),
	\dur, Pseq([1.5, 0.5, 2, 2, 2], inf)
);

~piano3 = Pbind(
	\instrument, \piano,
	\note, Pseq([
		[0, 4, 7],
		[-3, 0, 2, 6],
		[5, 9, 12],
		[0, 4, 7],
		[5, 9, 12, 16],
		[5, 8, 12, 16],
		[0, 4, 7]
	], inf),
	\dur, Pseq([1, 0.5, 0.5, 1, 0.5]/*[1, 1, 1, 1, 1, 1, 2]*/, inf)
);

~piano2 = Pbind(
	\instrument, \piano,
	\note, Pseq([
		[2, 5, 9, 12],
		[-3, 0, 4],
		[2, 5, 9, 12],
		[4, 7, 0],
		[5, 9, 12, 16],
		[2, 5, 9, 12],
		[5, 9, 12, 16]
	], inf),
	\dur, Pseq([0.5, 0.5, 1]/*[2, 2, 1.5, 0.5, 0.5, 0.5, 1]*/, inf)
);
)

(
//The four rhythmic patterns are defined here
~rhythm1 = Pbind(
    \instrument, \drum1,
    \dur, 1,
    \amp, 0.1,
    \pan, Pseq([-0.5, 0.5], inf));

~rhythm2 = Pbind(
    \instrument, \drum2,
    \dur, 0.25,
    \amp, Pseq([0.6, 0.5, 0.4, 0.3], inf),
    \freq, Pseq([400, 1000, 2000, 3000], inf),
    \decay, Pseq([0.05, 0.1, 0.15, 0.2], inf));

~rhythm3 = Pbind(
    \instrument, \drum1,
	\dur, Pseq([0.25, 0.125, 0.125, 0.25, 0.25, 1], inf),
    \amp, 0.1,
    \pan, Pseq([-0.5, 0.5], inf));

~rhythm4 = Pbind(
	\instrument, \drum2,
	\dur, Pseq([0.75, 0.25], inf),
    \freq, Pseq([1000, 2000], inf),
	\decay, Pseq([0.2, 0.15], inf));
)

(
// The four melodies are defined here.
var melodies = (
        lowMelody: Pseries(4, Prand(#[-2, -1, 1, 2], inf), inf).fold(-7, 11),
        highMelody: Pseries(14, Prand(#[-3, -2, 2, 3], inf), inf).fold(7, 18)
    );

//this Pbind was retrieved from https://ccrma.stanford.edu/~ruviaro/texts/A_Gentle_Introduction_To_SuperCollider.pdf (pg 38-39)
~melody1 = Pbind(
    \instrument, \piano,
	\degree, Pnsym1(Pwrand(#[lowMelody, highMelody], [0.7, 0.3], inf), melodies),
    \dur, Pwrand(#[0.25, 0.5], #[0.4, 0.6], inf),
);

~melody2 = Pbind(
	\instrument, \piano,
	\degree, Pseq([-2, -1, 1, 2, 4, 3, 2], inf),
	\dur, Pseq([0.5, 0.25, 0.5, 0.25, 0.5, 0.5, 0.5], inf),
);

~melody3 = Pbind(
	\instrument, \piano,
	\degree, Prand([0, 1, 2, 4, 5, 7], inf),
	\octave, Pseq([4, 5], inf),
	\dur, Prand([1, 0.5], inf),
);

~melody4 = Pbind(
    \instrument, \piano,
    \degree, Pseq([0, 2, 4, 7, 4, 2, 0], inf),
    \octave, Pseq([4, 5, 4, 5, 4, 5, 4], inf),
    \dur, Pseq([0.5, 0.25, 0.25, 0.5, 0.25, 0.25, 0.5], inf),
    \legato, 0.5,
);
)

(
// Create a new MusicClass for each type of music, and initialize it with a list of the corresponding patterns (which are stored as MoveClasses).
~chords = MusicClass.new(List[
	MoveClass.new('/1', '/3', ~piano1),
	MoveClass.new('/2', '/4', ~piano2),
	MoveClass.new('/3', '/1', ~piano3),
	MoveClass.new('/4', '/2', ~piano4)
]);

~rhythms = MusicClass.new(List[
	MoveClass.new('/1', '/2', ~rhythm1),
	MoveClass.new('/2', '/3', ~rhythm2),
	MoveClass.new('/3', '/4', ~rhythm3),
	MoveClass.new('/4', '/1', ~rhythm4)
]);

~melodies = MusicClass.new(List[
	MoveClass.new('/1', '/4', ~melody1),
	MoveClass.new('/2', '/1', ~melody2),
	MoveClass.new('/3', '/2', ~melody3),
	MoveClass.new('/4', '/3', ~melody4)
]);
)

(
//This part of the application responds to the data received from Wekinator
var responder1, responder2, responder3, responder4;

~receiver.free; //free the old reciever if it already exists
~receiver = NetAddr.new("127.0.0.1", 57120);    // create the NetAddr ... only the language port 57120 actually works

//there is one responder for each data output (because each is sent as a separate OSC message). In case an old responder exists, it is freed first.
~responder1.free;
~responder2.free;
~responder3.free;
~responder4.free;

//In each responder, each music type is updated with the new data. The toggleSound function determines whether the music needs to change in response to the data.
~responder1 = OSCFunc(
	{ | msg |
		~chords.toggleSound(msg[0]);
		~rhythms.toggleSound(msg[0]);
		~melodies.toggleSound(msg[0]);
	},
	'/1');

~responder2 = OSCFunc(
	{ | msg |
		~chords.toggleSound(msg[0]);
		~rhythms.toggleSound(msg[0]);
		~melodies.toggleSound(msg[0]);
	},
'/2');

~responder3 = OSCFunc(
	{ | msg |
		~chords.toggleSound(msg[0]);
		~rhythms.toggleSound(msg[0]);
		~melodies.toggleSound(msg[0]);
	},
'/3');

~responder4 = OSCFunc(
	{ | msg |
		~chords.toggleSound(msg[0]);
		~rhythms.toggleSound(msg[0]);
		~melodies.toggleSound(msg[0]);
	},
'/4');

)







