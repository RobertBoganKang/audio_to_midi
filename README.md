# Audio To MIDI
## Introduction
This method could convert Audio into MIDI (not target for music conversion).

There is also a KONTAKT virtual instrument `./src/generalMIDI.nki` created for this project using the samples in the source folder.
## Method
This is an optimization problem. 
### Assumption
* Assume that the sound quality will not change when volume changes.
* There is no physical resonance of piano strings.
* Sound volume is has linear relationship with piano weight of keys.
### Steps
We can do this in several steps:
* Let volume of the piano key is `v_i` at the key `i` (`v_i` is positive real number).
* Get the fourier feature from the sample file `f(i, omega)` (for this project is in `./src/samples` folder; MS General MIDI piano sound).
* Use the least square method to make sure that the fourier of target audio pieces largely close to the combination of fourier of samples (fourier has linear rule: `F(v_1 * wave_1(t) + v_2 * wave_2(t)) = v_1 * F(wave1(t)) + v_2 * F(wave2(t))`; where `F` is fourier transformation); namely the synthesized sound is `SUM` of `v_i * f(i, omega)` with index `i` (where `f(i, omega) = F(wave_i(t_sample))`, `omega` is the frequency), the fourier of original audio at position `t` is `a(t, omega)`; then try to minimize `(a(t, omega) - SUM(v_i * f(i, omega), i)) ^ 2` (quadratic polynomial: a much easier form to optimize) for all `omega`(s): 
```javascript
polynomial([v_i]) = SUM(omega) {
  synth_sound(omega) = SUM(i) {v_i * f(i, omega)};
  return (a(t, omega) - synth_sound(omega)) ^ 2;
};
MINIMIZE(polynomial([v_i])) // get all v_i numbers as volume for all piano keys
```
* For each `v_i`, if the values are too close with each other, combine them as one note on `v_i` ~ `t` domain for each key `i`.
* Generate MIDI file.
Notice: in these steps, we should set the threashold for fourier `f(i, omega)` and volume `v_i` to avoid calculations, since the volume is too low that we cannot hear it. In the test, I cannot notice the sound at almost `10^-3` ~ `10^-4`, so set the threas hold there.
## Other Info
This project seems time consuming in calculation not coding (rendering time more than coding) and it is not so useful, I am planning stop developing it.
### Deficiencies 
* Only sample rate at 44100 Hz is supported (no re-sample algorithm support). If using other sample rate, please change parameters in the code at system parameter section and make sure that the sample rate at samples and audio will be the same. 
* The optimization method optimized what people values. Since the human ear is sensitive to the sound volume at logarithm level, it is not theoretically correct to optimize the term mentioned above (although it is the most simple form; it is almost impossible to optimize such large functions with complicated forms when set the `log()` function in the program). In addition, the auditory mask is also a factor will affect, we will value more at some neighborhood of loud frequencies. Overall, it is somewhat reasonable to set this function considering all reasons above.
* The MIDI weight parameter value and volume value is not linearly related, we need to set function to increase the accuracy of the playback from the system.
* Although this algorithm audio is optimized on MS General MIDI sound, however the windows general MIDI never run properly on fast notes like this.
## Demo
### Song
Song: You Raise Me Up (calculate for 2 almost hours with 8 kernel CPU)

[Original file](https://github.com/RobertBoganKang/audio_to_midi/blob/master/demo/song%20original.ogg)
/
[MIDI file](https://github.com/RobertBoganKang/audio_to_midi/blob/master/demo/song.mid)
/
[Rendered MIDI file](https://github.com/RobertBoganKang/audio_to_midi/blob/master/demo/song%20render.ogg)
#### Videos
[Youtube](https://www.youtube.com/watch?v=qsCU_wfJiNk)
/
[YouKu](http://v.youku.com/v_show/id_XMzI5OTgwOTQwNA==.html?spm=a2h3j.8428770.3416059.1)
### Count
Voice: "one, two, three, four, five, six, seven, eight, nine, ten".

[Original file](https://github.com/RobertBoganKang/audio_to_midi/blob/master/src/count.wav)
/
[MIDI file](https://github.com/RobertBoganKang/audio_to_midi/blob/master/demo/count.mid)
/
[Rendered MIDI file](https://github.com/RobertBoganKang/audio_to_midi/blob/master/demo/count%20render.ogg)
### Love
Voice: "I love daddy".

[Original file](https://github.com/RobertBoganKang/audio_to_midi/blob/master/src/love.wav)
/
[MIDI file](https://github.com/RobertBoganKang/audio_to_midi/blob/master/demo/love.mid)
/
[Rendered MIDI file](https://github.com/RobertBoganKang/audio_to_midi/blob/master/demo/love%20render.ogg)
