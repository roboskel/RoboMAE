% RoboMAE, The Roboskel Multimodal Annotation Environment,
% is developed as part of Roboskel, the robotics activity
% of the Institute of Informatics and Telecommunications,
% National Centre for Scientific Research "Demokritos",
% Ag. Paraskevi, Greece
% Please see http://roboskel.iit.demokritos.gr
% or contact us at roboskel@iit.demokritos.gr
% 
% Copyright (C) 2012-2013, NCSR "Demokritos", Ag. Paraskevi, Greece
% Copyright (C) 2013, Konstantinos Tsiakas
% 
% Authors:
% Sergios Petridis, 2012
% Theodore Giannakopoulos, 2012-2013
% Konstantinos Tsiakas, 2013
% 
% This file is part of RoboMAE.
% 
% RoboMAE is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 2 of the License, or
% (at your option) any later version.
% 
% RoboMAE is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with RoboMAE.  If not, see <http://www.gnu.org/licenses/>.

%[y,c]=chroma_aggelos(x_in,Fs,winlength,step)
%USES SPECTRAL PEAKS ONLY and A HAMMING WINDOW multiplier
%x_in: 1-D COLUMN vector
%Fs: sampling frequency
%winlength: moving window length (samples)
%step: moving window step (samples)
%y: sequence of chroma vectors. Each bin of each chroma vector is a sum of
%   FFT amplitudes
%c: sequence vectors that indicates, for each chroma-vectro, the number of
%   Fourier coefs that take part in the respective bin. This is useful when
%   it comes to calculating the man value at each bin

function [C, y,c]=chroma_aggelos(x_in,Fs)

x_in = x_in / max(abs(x_in));
tone_analysis=12;
num_of_bins=12;

[mm,nn]=size(x_in);
if nn>1
    x_in=x_in';
end

l=1;
y=[];
c=[];
lengthx=length(x_in);
winlength = lengthx;
freqs=0:Fs/winlength:(floor(winlength/2)-1)*(Fs/winlength);
f0=55;
i=0;
while (1) % define the chromatic scale on the frequency axis
    f(i+1)=f0*2^(i/tone_analysis);
    if f(i+1)>freqs(length(freqs))
        f(i+1)=[];
        break
    end
    i=i+1;
end

time_vector=[];
    
    x = x_in;      
    fftMag=abs(fft(x))';
    fftMag=fftMag(1:floor(winlength/2));
    
    the_max=max(fftMag); %checking for very low-energ frames
    if the_max<=eps
        ytemp=zeros(num_of_bins,1);
        y=[ytemp];
    end
        
    dfind=find(freqs<f(1) | freqs>2000);
    fftMag(dfind)=zeros(1,length(dfind));    

    %Keep spectral PEAKS ONLY (can be omitted)
    c1=fftMag-[0 fftMag(1:length(fftMag)-1)];
    c2=[fftMag]-[fftMag(2:length(fftMag)) 0];
    dfind=find(~(c1>0 & c2>0));
    fftMag(dfind)=zeros(1,length(dfind));          
  
    nonzero=find(fftMag>0);
    if isempty(nonzero)
        y=zeros(num_of_bins,1);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    

    ytemp=zeros(num_of_bins,1);
    ctemp=zeros(num_of_bins,1);
    for k=1:length(nonzero)
        temp=freqs(nonzero(k));
        %N=hist(temp,f);                
        %pitch_class=find(N==1);
        [MIN, IMIN] = min(abs(temp-f));
        pitch_class = IMIN;
        h=rem(pitch_class,num_of_bins);
        if h==0
            h=num_of_bins;
        end
        ytemp(h)=ytemp(h)+fftMag(nonzero(k));
        ctemp(h)=ctemp(h)+1;
    end
    
    y=ytemp;
    c=ctemp;

% WHY????????????????
[K1,L1] = size(y);
[K2,L2] = size(c);
if (L1~=L2)
    c = imresize(c,size(y));
end
C = y./(c+1);