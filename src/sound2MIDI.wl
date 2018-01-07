(* ::Package:: *)

sound2MIDI[file_]:=Module[{sampletime,threashold,intervaltime,samplerate,cutresultlow,modelvalue,data,sampledata,fourier,audiodata,audiofourier,fourierdata,keyresult,key,audiomodel,start,i,result,audioendingtime,tolerance,resultsounddata},
(*system parameters*)
sampletime=.1;threashold=.01;intervaltime=0.05;samplerate=44100;cutresultlow=0.0001;
(*build model function from samples*)
If[!ListQ[modelfunction],modelfunction=Total[ParallelTable[data=Import[NotebookDirectory[]<>"samples/"<>ToString[i]<>".wav","Data"];samplerate=Import[NotebookDirectory[]<>"samples/"<>ToString[i]<>".wav","Sound"][[1,2]];sampledata=First[data][[;;samplerate*sampletime]];
fourier=Abs[Fourier[sampledata][[;;Round[sampletime*samplerate/2]]]];
Do[If[fourier[[i]]<threashold,fourier[[i]]=0],{i,Length[fourier]}];
fourier*ToExpression["x"<>ToString[i]],{i,88}]];];
(*audio data*)audiodata=Import[file,"Data"];audiodata=audiodata[[1]];
audiodata/=Max[audiodata];
audioendingtime=Length[audiodata]/samplerate*1.;
(*create fourier slices for audio*)audiomodel=ParallelTable[audiofourier=Abs[Fourier[audiodata[[Round[j*intervaltime*samplerate]+1;;Round[j*intervaltime*samplerate]+1+sampletime*samplerate]]][[;;Round[sampletime*samplerate/2]]]];
Do[If[audiofourier[[i]]<threashold,audiofourier[[i]]=0],{i,Length[audiofourier]}];audiofourier,{j,(Length[audiodata]-1-sampletime*samplerate)/(intervaltime*samplerate)}];
(*optimization model to sound volumes*)
result=ParallelTable[fourierdata=audiomodel[[i]];modelvalue=FindMinimum[{Expand[Total[(fourierdata-modelfunction)^2]],Table[ToExpression["x"<>ToString[i]]>0,{i,88}]},Table[{ToExpression["x"<>ToString[i]],0},{i,88}],AccuracyGoal->7,PrecisionGoal->9];modelvalue[[2,;;,2]],{i,Length[audiomodel]}];result/=Max[result];
(*generate sound*)
(*resultsounddata=Flatten[Table[If[result[[i,j]]<cutresultlow,{},SoundNote[j-40,{(i-1)*intervaltime,i*intervaltime},SoundVolume->result[[i,j]]]],{i,Length[result]},{j,88}]];Sound[resultsounddata]*)
keyresult=Transpose@result;
resultsounddata={};tolerance=0.01;
Do[start=i=2;
While[i<=Length[keyresult[[key]]],
If[keyresult[[key,i]]>cutresultlow,If[Abs[keyresult[[key,i]]-keyresult[[key,i-1]]]>tolerance,
AppendTo[resultsounddata,SoundNote[key-40,{(start-1)*intervaltime,(i-1)*intervaltime},SoundVolume->keyresult[[key,i]]]];start=i
(*else*)
];,
start=i];i++],{key,88}];
AppendTo[resultsounddata,SoundNote[0,{audioendingtime+.1,audioendingtime+1.6},SoundVolume->1/4]];
answer=resultsounddata;Export[NotebookDirectory[]<>"test.mid",Sound[resultsounddata]];Sound[resultsounddata]]
