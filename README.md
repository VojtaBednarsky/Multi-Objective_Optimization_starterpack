Overview:
This repository contains a MATLAB script for optimizing a planar monopole antenna
using a combination of Artificial Neural Networks (ANN) and Non-Dominated Sorting Genetic Algorithm II (NSGA-II). 
The script automates the design and evaluation process to enhance the antenna’s performance across multiple objectives.

How It Works

	1.	Initialization: The script initializes parameters such as frequency range, design variables, and optimization constraints. 
      It also prepares files for logging results and sets up ANN models for evaluating antenna performance.
	2.	Optimization Process: Using NSGA-II, the script performs multi-objective optimization to find the best antenna designs. 
      It iterates through multiple generations, adjusting design variables to improve performance metrics.
	3.	Simulation and Evaluation: For each design, the script performs simulations using CST Microwave Studio, calculates S-parameters, and evaluates the fitness of each design. 
      The results are compared with ANN predictions to refine the model.
	4.	Results Analysis: The script plots the Pareto front of optimal solutions and tracks convergence over iterations. 
      It provides insights into the trade-offs between different performance metrics and saves results for further analysis.

Key Features:

	•	Automated design optimization with NSGA-II
	•	Integration with CST Microwave Studio for simulation
	•	Real-time plotting of Pareto fronts and convergence trends
	•	Data logging and analysis for continuous improvement
