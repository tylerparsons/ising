%%  
%   An IsingModel class that contains a system
%   of spin lattices and provides support for
%   controlling and running simulations.
%
classdef IsingModel < handle
    
    properties (SetAccess = private)
        system      % Member SpinLattice
        steps       % Duration of simulation
        displaymod  % step interval between plot rendering
    end
    
    properties (Constant)
        % Boltzmann's constant
        k = 1.381e-23;
        % Relative path of file to which to append data
        csvpath = 'data.csv';
    end
    
    methods
        
        % Constructor
        function [im] = IsingModel(L, H, T, steps, g)
            if g == 't'
                im.system = TriangularSpinLattice(L, H, T, steps);
            elseif g == 's'
                im.system = SquareSpinLattice(L, H, T, steps);
            end
            im.steps = steps;
            im.displaymod = steps/100;
        end
        
        % Runs simulation for the given
        % number of steps.
        function run(this)   
                        
            for i = 1:this.steps
                % Execute a single step
                flipped = this.system.step();
                % Draw if a flip was made
                if flipped && mod(i, this.displaymod) == 0
                    drawnow;
                end
            end
 
            % Write data to file
            fileID = fopen('data.csv', 'a');
            % Add additional parameters here to save them
            fprintf(...
                fileID,...
                '%i\t%i\t%6.2f\t%i\t%12.8f\n',...
                [
                    this.system.getL()
                    this.system.getH()
                    this.system.getT()
                    this.steps
                    this.system.susceptibility()
                ]...
            );
            fclose(fileID);
            
            %Display susceptibility
            disp(['x/KLH = ' num2str(this.system.susceptibility())]);
            % Add display of other data here
            % ...
            % ...
            
        end
        
    end
    
end