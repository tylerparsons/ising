%%  
%   Runs a single trial over the given
%   number of steps at temperature T.  
%   Chooses a lattice with the given 
%   geometry g, either 't' for 
%   triangular or 's' for square.
%
function ising(L, H, T, steps, g)
        
    % Output paramters to console
    disp(['L = ' num2str(L)]);
    disp(['H = '  num2str(H)]);
    disp(['T = '  num2str(T)]);
    disp(['steps = '  num2str(steps)]);
    if g == 't'
        disp('geometery = triangular (n = 6)');
    elseif g == 's'
        disp('geometery = square (n = 4)');
    end
    
    % Run simulation
    im = IsingModel(L, H, T, steps, g);
    im.run();

end