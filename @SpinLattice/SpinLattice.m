%%  
%   A representation of a ferromagnet as a 2D
%   lattice structure storing particles, each
%   with a spin of +1 or -1. This class enables
%   simulation of the behavior of this system
%   with the Metropolis Algorithm.
%
%   Additionally, this class provides support
%   for the calculation of various system
%   properties such as the magnetization,
%   susceptibility and the correlation function,
%   as well as some of their associated
%   expectation values.
%
%   This is an abstract class, in that it is
%   not specific to a particular 2D lattice
%   geometry. It must be extended to be used in
%   a simulation. This library provides built in
%   implementations for square and triangular
%   lattices.
%
classdef SpinLattice < handle
    
    % Instance properties
    properties (SetAccess = protected)
        
        %%% Physical Properties %%%
        spins % Matrix storing lattice spins
        w     % Vector storing Boltmann factors
              % for possible values of dE
        c     % Matrix storing correlation function
              % values for corresponiding r values
        L     % Length
        H     % Height
        T     % Temperature
        t     % Time (measured in steps)
        St_M  % Sum over all t of magnetization M
        St_M2 % Sum over all t of magnetization squared
        
    end
    
    % Constant Properties
    properties (Constant)
        
        %%% Analysis Parameters %%%
        calcmod = 100;      % The step interval at which
                            % to make analysis calculations
        
        %%% Visualization Parameters %%%
        markerscale = 350;  % Plot marker size
        plotdimen = 600;    % Plot height/width
        plotleft = 50;      % Plot horizontal position
        plotbottom = 50;    % Plot vertical position
        redblue = [         % Matrix of plot colors
            0 0 1           % blue - maps to spin -1
            1 0 0           % red	- maps to spin +1
        ];
        
    end
    
    % Inherited methods
    methods (Static = false)
        
        % Constructor
        function [lattice] = SpinLattice(L, H, T, steps)
            
            % Create vertex matrix
            lattice.spins = zeros(L, H);
            % Initialize to random spin
            for i = 1:L
                for j = 1:H
                    if rand < 0.5
                        lattice.spins(i, j) = 1;
                    else
                        lattice.spins(i, j) = -1;
                    end
                end
            end
            
            % Initialize correlation function matrix
            lattice.c = zeros(steps/lattice.calcmod, 2);
            
            % Store L, H and T as instance variables
            lattice.L = L;
            lattice.H = H;
            lattice.T = T;
            
            % Initialize other variables
            lattice.St_M = 0;
            lattice.St_M2 = 0;
            
            % Compute Boltzmann factors
            lattice.initW();
            
            % Setup visualization
            lattice.initPlot();
            
            % Intitialtize time to 0
            lattice.t = 0;
            
        end
        
        % Performs initial plot setup to save computation
        % time in later calls to draw.
        function initPlot(this)
            
            clf;
            % Size plot
            fig = figure(1);
            set(fig, 'Position', [
                this.plotleft this.plotbottom ...
                this.plotdimen this.plotdimen
            ]);
            % Set colormap
            colormap(this.redblue);
            % Turn off axes
            axis off;
            % Plot all points once initially
            this.plotAll();
            
        end
        
        % Perform one step of the Metropolis Algorithm.
        % Returns true if a flip was made, else false.
        function [flipped] = step(this)
            
            % Choose random vertex
            i = randi(this.L);
            j = randi(this.H);
            % Compute change in energy from flip at (i, j)
            dE = this.dE(i, j);
            
            %%% Determine if flip should be made %%%
            if dE <= 0 || (rand < this.w(dE))
                
                % State is either favorable or probable
                % according to Boltzmann factor of dE.
                % Flip!
                this.spins(i, j) = -this.spins(i, j);
                flipped = true;
                
                % Plot addl point
                this.plotPoint(i, j);
                
                % Compute sums for average values
                M = this.M();
                this.St_M = this.St_M + abs(M);
                this.St_M2 = this.St_M2 + M*M;
                
                % Conduct other, periodic analysis
                if mod(this.t, this.calcmod) == 0
%                     this.calcCorrelationFunction();
                end
            else
                flipped = false;
            end
            
            % Increment time
            this.t = this.t + 1;
            
        end
        
        %%% Calculations %%%
        
        % Calculates the total magnetization
        % of the system in its current state
        function [M] = M(this)
            M = 0;
            for y = 1:this.H
                for x = 1:this.L
                    M = M + this.spins(x, y);
                end
            end
        end
        
        % Calculates the time averaged
        % magnetization of the system
        function [M_avg] = M_avg(this)
            M_avg = this.St_M / (this.t + 1);
        end
        
        % Calculates the average magnetization
        % squared of the system
        function [M2_avg] = M2_avg(this)
            M2_avg = this.St_M2 / (this.t + 1);
        end
        
        % Calculates the quantity x/KLH for this
        % system 
        function [x] = susceptibility(this)
            % Eliminate M in favor of of m = M/L^2
            % since x = KLH(<m^2> - <|m|>^2) = K(<M^2> - <|M|>^2)
            M_avg = this.M_avg();
            x = (this.M2_avg() - M_avg*M_avg) ...
                /(this.L*this.H);
        end
        
        % Calculates the correlation function by
        % choosing a random separation distance r
        % between two dipoles from 1 to L/2 and
        % computes the quantity <s_is_j>-<s_i>^2
        % for all dipoles with neighbors at r.
        % Stores the result in a matrix of r and
        % c values.
        function calcCorrelationFunction(this)
            
            % Define quantities
            s_is_j = 0;         % <s_is_j>
            s_i = 0;            % <s_i>
            r = randi(this.L/2);% |i - j|
            n = 0;              % samples
            
            % Examine all dipole pairs with 
            % separation distance r            
            for y = 1:this.H
                for x = 1:this.L
                    % Check left
                    if x + r <= this.L
                        % Compute running averages
                        s_is_j = (s_is_j * n ...
                               + this.spins(x, y)*this.spins(x+r, y))...
                               / (n+1);
                        s_i = (s_i * n + this.spins(x, y))/++n;
                    end
                    % Check down
                    if y + r <= this.H
                        % Compute running averages
                        s_is_j = (s_is_j * n ...
                               + this.spins(x, y)*this.spins(x, y+r))...
                               / (n+1);
                        s_i = (s_i * n + this.spins(x, y))/++n;
                    end
                    % No need to check up or right since
                    % starting from top left
                end
            end
            
            % Store correlation function values for later analysis
            
        end
        
        %%% Visualization Methods %%%
        
        % Draws this lattice
        function draw(this)
            clf;
            imagesc(this.spins);
            axis off;
            drawnow;            
        end
        
        function plotAll(this)
            
            for y = 1:this.H
                for x = 1:this.L
                    this.plotPoint(x, y);
                end
            end
            
        end
        
        function plotPoint(this, x, y)
            hold on
            if this.spins(x, y) == 1
                plot(x, y, 's',...
                    'MarkerFaceColor','r',...
                    'MarkerEdgeColor','none',...
                    'MarkerSize', this.markerscale/this.H);
            else
                plot(x, y, 's',...
                    'MarkerFaceColor','b',...
                    'MarkerEdgeColor','none',...
                    'MarkerSize', this.markerscale/this.H);
            end
            hold off
        end
        
    end
    
    % Subclass specific methods
    methods (Abstract)
        
        % Computes the change in energy of 
        % flipping spin at (x,y), which depends
        % on particular lattice geometry
        dE(this, x, y)
        
        % Sets w for the allowed values of dE
        initW(this)
        
    end
    
    % Getters
    methods
        
        function L = getL(this)
            L = this.L;
        end
        
        function H = getH(this)
            H = this.H;
        end
        
        function T = getT(this)
            T = this.T;
        end
        
    end
    
end