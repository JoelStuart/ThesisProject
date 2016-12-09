echo off
set PATH=F:\Programs\Microsoft Visual Studio 11.0\VC\bin;%PATH%
set PATH=C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v7.5\bin;%PATH%
call vcvars32.bat
nvcc %1 %2 %3 %4 %5 %6 %7 %8 %9 
