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

function [dJoint, dMax, Admax] = computeInformationMeasuresForClustering(n)

N = sum(sum(n));
a = sum(n, 2);
b = sum(n, 1);
R = size(n, 1);
C = size(n, 2);

% Compute Entropy: (+eps is used for the case of zero log arg
H_u = -sum( ((a+eps)/N) .* log((a+eps)/N) );
H_v = -sum( ((b+eps)/N) .* log((b+eps)/N) );

% Compute joint entropy:
H_uJv = -sum(sum( ((n+eps)/N) .* log((n+eps)/N) ));

% Compute conditional entropy H(U|V):
H_uCv = 0.0;
for (i=1:R)
    for (j=1:C)
        H_uCv = H_uCv - ((n(i,j)+eps) / N) * log ( (n(i,j)+eps) / (b(j)+eps) );
    end
end


% Compute Mutual Information:
I_uv = 0.0;
for (i=1:R)
    for (j=1:C)
        I_uv = I_uv + ((n(i,j)+eps) / N) * log ( (n(i,j)+eps) / ( (a(i)*b(j)+eps) / N) );
    end
end

% Compute expectated value E_I_uv:
E_I_uv = 0.0;
for (i=1:R)
    for (j=1:C)
        MIN = max([0 a(i)+b(j)-N]);
        MAX = min([a(i), b(j)]);
        for (nij=MIN:MAX)
            term1 = ( (nij+eps)/N) * log( (N*nij+eps)/(a(i)*b(j)+eps) );
            %term2Num = factorial(a(i)) * factorial(b(j)) * factorial(N-a(i)) * factorial(N-b(j));
            %term2Den = factorial(N) * factorial(nij) * factorial(a(i)-nij) * factorial(b(j)-nij) * factorial(N-a(i)-b(j)+nij);            
            
            term2 = frac_factorial([a(i) b(j) N-a(i) N-b(j)], [N nij a(i)-nij b(j)-nij N-a(i)-b(j)+nij]);
            %fprintf('%d %d %d %.2f\n',i, j, nij, term2);
            %E_I_uv = E_I_uv + term1 * term2Num / term2Den;
            E_I_uv = E_I_uv + term1 * term2;
        end
    end
end

% The following information measures have been computed:
% [H_u, H_v, H_uJv, H_uCv, I_uv, E_I_uv]
dJoint = 1 - I_uv / H_uJv;
dMax   = 1 - I_uv / max([H_u H_v]);
% STEP 2: compute Adjusted for change distance measures:
Admax = 1 - (I_uv-E_I_uv) / (max([H_u H_v])-E_I_uv);