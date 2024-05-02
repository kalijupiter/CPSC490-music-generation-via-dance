/* This file contains class definitions.
From https://doc.sccode.org/Guides/WritingClasses.html: Class definitions are statically compiled when you launch SuperCollider or "recompile the library." This means that class definitions must be saved into a file with the extension .sc, in a disk location where SuperCollider looks for classes. Saving into the main class library (SCClassLibrary) is generally not recommended. It's preferable to use either the user or system extension directories. */


/* The MoveClass contains each pattern of music, along with the pair of indexes for the movements that must be recognized for the music to be played */
MoveClass {
	var indexA, indexB, sound;
	var toggleA = 0;
	var toggleB = 0;

	*new{ |indexA, indexB, sound |
		^super.newCopyArgs(indexA, indexB, sound)
	}

	indexA {
		^indexA
	}

	indexB {
		^indexB
	}

	sound {
		^sound
	}

	toggleA {
		^toggleA
	}

	toggleB {
		^toggleB
	}

	/* This method updates toggles when based on the messages received from Wekinator */
	updateToggle { |msg|
		//the state changes based on toggleA. When toggle A is 0, the first move hasn't been recognized, and it changes to 1 once that move is seen. The same is true for toggleB
		switch(toggleA,
		{ 0 }, {
			if (msg == indexA, {
					toggleA = 1;
			});
		},

		{ 1 }, {
			if (msg == indexB, {
					toggleB = 1;
			}, {
					toggleB = 0;
					toggleA = 0;
			});
		})
	}
}


/* The MusicClass contains the list of possible MoveClasses for that music type and a music player. It also tracks the current move being played. */
MusicClass {
	var moves;
	var currMove = -1;
	var player;

	*new{ | moves |
		^super.newCopyArgs(moves)
	}

	/* This method passes the latest Wekinator message to each MoveClass in the list. After the toggles are updated, if toggleB is 1 for that MoveClass, the corresponding music is played (because this means both moves were recognized consecutively) */
	toggleSound { | msg |
		var bestFreq = 0;
		var bestIndex = -1;
		moves.do({
			arg item, i;
			item.updateToggle(msg);
			if ((item.toggleB == 1) && (currMove != i), {
				player.stop;
				player = moves[i].sound.play(quant: [1, 0, 0]);
				currMove = i;
			});
		});

		^currMove;
	}
}


