%%  
%   Runs multiple trials from Ti to Tf at
%   intervals of dT, each over the given
%   number of steps.  Chooses a lattice
%   with the given geometry g, either 't'
%   for triangular or 's' for square.
%
function isingTrials(L, H, Ti, Tf, dT, steps, g)

    T = Ti;    
    while T <= Tf
        disp('---------------------');
        ising(L, H, T, steps, g)
        T = T + dT;
    end

end