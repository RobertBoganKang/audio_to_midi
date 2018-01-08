(* ::Package:: *)

sound2MIDI[file_]:=Module[{sampletime,threashold,intervaltime,samplerate,cutresultlow,modelvalue,data,sampledata,fourier,audiodata,audiofourier,fourierdata,keyresult,key,audiomodel,start,i,result,audioendingtime,tolerance,resultsounddata},
(*system parameters*)
(*sample time for fourier analysis*)sampletime=.1;
(*threashold for valid fourier values*)threashold=0.0001;
(*time division of analysis for audio*)intervaltime=0.05;
(*samplerate: only 44100 is supported [both samples and audio]*)samplerate=44100;
(*cut the fourier underflow*)cutresultlow=0.0001;
(*cut the underflow for generating MIDI*)tolerance=0.1;
(*build model function from samples*)
If[!ListQ[modelfunction],
(*model function for samples to build polynomial function*)
modelfunction=Total[Table[data=Import[NotebookDirectory[]<>"samples/"<>ToString[i]<>".wav","Data"];
sampledata=First[data][[;;samplerate*sampletime]];
fourier=Abs[Fourier[sampledata][[;;Round[sampletime*samplerate/2]]]];
Do[If[fourier[[i]]<threashold,fourier[[i]]=0],{i,Length[fourier]}];
fourier*ToExpression["x"<>ToString[i]],{i,88}]];];
(*audio data*)audiodata=Import[file,"Data"];audiodata=Mean[audiodata];
audiodata/=Max[audiodata];
audioendingtime=Length[audiodata]/samplerate*1.;
(*create fourier slices for audio*)audiomodel=ParallelTable[audiofourier=Abs[Fourier[audiodata[[Round[j*intervaltime*samplerate]+1;;Round[j*intervaltime*samplerate]+1+sampletime*samplerate]]][[;;Round[sampletime*samplerate/2]]]];
Do[If[audiofourier[[i]]<threashold,audiofourier[[i]]=0],{i,Length[audiofourier]}];audiofourier,{j,(Length[audiodata]-1-sampletime*samplerate)/(intervaltime*samplerate)}];
(*optimization model to sound volumes*)
Clear[ii,ll];ll=Length[audiomodel];ii=0;
SetSharedVariable[ii];
Paste[Dynamic[ProgressIndicator[ii/ll]]];
result=ParallelTable[ii++;fourierdata=audiomodel[[i]];modelvalue=FindMinimum[{Expand[Total[(fourierdata-modelfunction)^2]],Table[ToExpression["x"<>ToString[i]]>0,{i,88}]},Table[{ToExpression["x"<>ToString[i]],0},{i,88}],AccuracyGoal->7,PrecisionGoal->9];modelvalue[[2,;;,2]],{i,Length[audiomodel]}];result/=Max[result];
(*generate sound*)
(*resultsounddata=Flatten[Table[If[result[[i,j]]<cutresultlow,{},SoundNote[j-40,{(i-1)*intervaltime,i*intervaltime},SoundVolume->result[[i,j]]]],{i,Length[result]},{j,88}]];Sound[resultsounddata]*)
keyresult=Transpose@result;
resultsounddata={};
Do[start=i=2;
While[i<=Length[keyresult[[key]]],
If[keyresult[[key,i]]>cutresultlow,If[keyresult[[key,i]]<keyresult[[key,i-1]]||Log[keyresult[[key,i]]]-Log[keyresult[[key,i-1]]]>tolerance,
AppendTo[resultsounddata,SoundNote[key-40,{(start-1)*intervaltime,(i-1)*intervaltime},SoundVolume->keyresult[[key,i]]]];start=i
(*else*)
];,
start=i];i++],{key,88}];
(*add default beep*)
AppendTo[resultsounddata,SoundNote[0,{audioendingtime+.1,audioendingtime+1.6},SoundVolume->1/4]];
answer=resultsounddata;
(*backup midi*)Export[NotebookDirectory[]<>"test.mid",Sound[resultsounddata]];
Sound[resultsounddata]]
