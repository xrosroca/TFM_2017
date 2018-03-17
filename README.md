# Analyzing SPSA approaches to solve the non-linear non-differentiable problems arising in the assisted calibration of traffic simulation models

Master thesis for Master in Statistics and Operations Research at Universitat Politècnica de Catalunya (MESIO UPC-UB, Barcelona, Spain)

## Professors 

* Jaume Barceló (UPC-DEIO)
* Lidia Montero (UPC-DEIO)

## Abstract

Mathematical and simulation models of systems lay at the core of decision support systems, and their role become more critical as more complex is the system object of decision. The decision process usually encompasses the optimization of some utility function that evaluates the performance indicators that measure the impacts of the decisions. An increasing difficulty directly related to the complexity of the system arises when the associated function to be optimized is a not analytical, non-differentiable, non-linear function which can only be evaluated by simulation. Simulation-Optimization techniques are especially suited in these cases and its use is increasing in traffic models, an archetypic case of complex, dynamic systems exhibiting highly stochastic characteristics. In this approach simulation is used to evaluate the objective function, and a non-differentiable optimization technique to solve the optimization problem is used. *Simultaneous Perturbation Stochastic Approximation* (SPSA) is one of the most popular of these techniques.

This thesis analyzes, discusses and presents computational results for the application of this technique to the calibration of a traffic simulation model of a Swedish highway section. Variants of the SPSA, replacing the usual gradient approach by a combination of normalized parameters and penalized objective function, have been proposed in this study due to an exhaustive analysis of the behavior of classical SPSA where problems arose from different magnitude variables.

In this work, a varied set of Software environments have been used, combining *RStudio* for the analysis, *Python* and *MATLAB* for the SPSA implementation, *AIMSUN* as a Traffic Model Simulator, and *SQLite* for obtaining of simulated data and *Tableau* for visualizing data and results.

## Links

* To the Thesis: [here](https://upcommons.upc.edu/handle/2117/100675)
* To the Results: [here](https://public.tableau.com/profile/xavier.ros.roca#!/)
* To the published article: [here](https://www.sciencedirect.com/science/article/pii/S235214651730995X)
