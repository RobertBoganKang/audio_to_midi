# Audio To MIDI
## Introduction
This method could convert Audio into MIDI (not target for music conversion).

It is just fun to do this.
## Method
This is an optimization problem. 
### Assumption
* Assume that the sound quality will not change when volume changes.
* There is no physical resonance of piano strings.
### Steps
We can do this in several steps:
* Assume that the volume of the piano key is `v_i` at the key `i`.
* Get the fourier feature from the sample file `f(i, omega)`, where `omega` is the frequency (this project is in `./src/samples` folder; MS General MIDI piano sound).
* Use the least square method to make sure that the fourier of target audio pieces largely close to the combination of fourier of samples; namely the synthesized sound is `SUM` of `v_i*f(i, omega)` with index `i`, the fourier of original audio at position `t` is `a(t,omega)`; then try to minimize `(a(t, omega)-SUM(v_i*f(i, omega), i))^2` for all `omega`s: 
```javascript
polynomial([v_i]) = SUM(omega) {
  synth_sound(omega) = SUM(i) {v_i*f(i,omega)};
  return (a(t, omega) - synth_sound(omega))^2;
};
MINIMIZE(polynomial([v_i])) // get all v_i numbers as volume for all piano keys
```
* For each `v_i`, if the values are too close with each other, combine them as one note.
* Generate MIDI file.
Notice: in these steps, we should set the threashold for fourier `f(i, omega)` and volume `v_i` to avoid calculations, since the volume is too low that we cannot hear it.
## Demo
### Count
Voice: "one, two, three, four, five, six, seven, eight, nine, ten".

[Original file](https://github.com/RobertBoganKang/audio_to_midi/blob/master/src/count.wav)

[MIDI file](https://github.com/RobertBoganKang/audio_to_midi/blob/master/demo/count.mid)

[Rendered MIDI file](https://github.com/RobertBoganKang/audio_to_midi/blob/master/demo/count%20render.ogg)
### Love
Voice: "I love daddy".

[Original file](https://github.com/RobertBoganKang/audio_to_midi/blob/master/src/love.wav)

[MIDI file](https://github.com/RobertBoganKang/audio_to_midi/blob/master/demo/love.mid)

[Rendered MIDI file](https://github.com/RobertBoganKang/audio_to_midi/blob/master/demo/love%20render.ogg)
