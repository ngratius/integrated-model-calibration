# Integrated model calibration

Integrated Calibration of Simulation Models for Autonomous Space Habitat Operations

Related publication: IEEE Aerospace 2024 (in production)

## Description

Space habitats for exploration beyond low earth orbit need to provide the crew with enhanced capabilities for earth-independent operations. Mission control has traditionally been the main decision maker in anomaly response procedures, but this role will be limited in deep space due to increased communication delays. Digital simulation models are used by ground control for troubleshooting tasks and are likely to be essential assets for the crew to test “what-if” scenarios when important faults are detected onboard. Migrating models from mission control to a space habitat is however challenging as these models are typically heterogeneous and rely on the knowledge of sub-system specialists to be operated. Efforts have been made to automate the integration of multiple simulation models, but their calibration, i.e., the assignment of model parameters that best represent the system behavior, typically remains expert-driven and focused on individual models. To alleviate this reliance on experts and facilitate integration without human intervention, we propose leveraging the interpretable representation ability of probabilistic graphical models to encode dependencies between simulation models at the time of calibration. In this mathematical abstraction, nodes represent random variables, and edges embed causal relationships as conditional probability distributions. We build a graphical model hierarchically with a first layer of nodes representing subsystem states, and a second layer for the simulation model parameters, e.g., a set of possible slopes and intercepts of a regression model. The two layers are mapped probabilistically using domain knowledge from sub-system specialists thereby enabling the migration of reasoning capabilities from mission control to a space habitat. The created network is used to infer the most likely set of simulation parameters given the believed system state which is derived from a diagnosis module. We study the proposed mechanism by implementing it in a docking scenario. In this scenario, the crew of an incoming vehicle is performing a system readiness check before docking to a space station. An algorithm detects a CO2 removal fault, and we perform calibration accordingly using a graphical model. Three types of simulation models are being integrated via calibration, namely: (i) machine learning models trained on empirical data from a testbed of the ISS Carbon Dioxide Removal Assembly, (ii) physics-based models that were designed for this same testbed and (iii) knowledge-based models derived from NASA’s flight rules on admissible CO2 concentrations in a space habitat. We explore a method to implement such a graphical model that consists of (i) selecting a subset of system states as degrees of faulty behaviors, (ii) identifying their dependencies, i.e., defining the likelihood of cascading fault symptoms across subsystems, and (iii) selecting the simulation models that are expected to provide the most insight onboard and which can be parameterized given the network of system states established in the previous two steps. Our study reveals challenges that are to be solved for implementing this graphical model-based calibration. Specifically, it identifies a need to formalize the creation of the network for the subsystem states and to assess how to leverage existing standards for simulation model interfaces.

## Dependencies

This project relies on the following Python packages:

- pandas
- numpy
- torch
- scikit-learn
- matplotlib
- blitz
- pgmpy
- networkx

Additionally, you need to have MATLAB installed on your system for the following code block to work:

```python
import matlab.engine
```

## Authors

* [Nicolas Gratius](https://www.linkedin.com/in/nicolas-gratius-3360b0110/)

* [Mario Bergés](https://www.cmu.edu/cee/people/faculty/berges.html)

* [Burcu Akinci](https://www.cmu.edu/cee/people/faculty/akinci.html)

## Acknowledgments

[NASA grant 80NSSC19K1052](https://govtribe.com/award/federal-grant-award/grant-for-research-80nssc19k1052)
