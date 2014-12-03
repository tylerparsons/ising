%%  
%   Runs multiple trials from Ti to Tf at
%   intervals of dT, each over the given
%   number of steps.
function isingTrials(L, H, Ti, Tf, dT, steps)

    T = Ti;    
    while T <= Tf
        disp('---------------------');
        ising(L, H, T, steps)
        T = T + dT;
    end

end