%%  
%   Runs a single trial over the given
%   number of steps at temperature T.
%
function ising(L, H, T, steps)
        
    % Output paramters to console
    disp(['L = ' num2str(L)]);
    disp(['H = '  num2str(H)]);
    disp(['T = '  num2str(T)]);
    disp(['steps = '  num2str(steps)]);

    % Run simulation
    im = IsingModel(L, H, T, steps);
    im.run();

end