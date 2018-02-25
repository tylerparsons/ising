# IsingModelSimulation

An object oriented MATLAB library for simulating the Ising Model and determining the critical temperature Tc.

## Download and Setup

Clone the library into a folder on the MATLAB path.

## Running the Simulation

Run a single simulation by typing the command

```ising(L, H, T, steps, g)```

where

	L = length (an integer),
	H = height (an integer),
	T = temperature,
	steps = number of iterations,
	g = geometry (either 't' for triangular of 's' for square).
	
To run multiple simulations, use the command
	
```isingTrials(L, H, Ti, Tf, dT, steps, g)```

which creates and simulates multiple systems each with a temperature between Ti and Tf inclusive at intervals of dT.

## Collecting Data and Calculating Tc

At the end of each trial, the susceptibility x/KLH of the system is printed and saved to the csv file ```data.csv```.

This quantity is a maximum at T = Tc, thus Tc can be determined by running many trials.

## Error Reduction

To reduce error in the calculation of Tc, use large systems, where L, H > 40.

Additionally, run many trials for a given T and average x/KLH values before determining peak susceptibility.

## Model Extension

Feel free to branch and add analysis functionality to the model.  Experimentation is encouraged!

## Help

Type ```help [identifier]``` for documentation on any script or class in the library.
