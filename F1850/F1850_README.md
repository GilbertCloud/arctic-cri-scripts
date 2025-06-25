# F1850

The F1850 experiment was run using CESM release tags 'release-cesm2.2.0' on Cheyenne and 'release-cesm2.2.2' on Derecho. 

## Directories

- 240K_C: namelists from the Cheyenne portion of the 24OK optics F1850 case
- 273K_C: namelists from the Cheyenne portion of the 273K optics F1850 case
- control_C: namelists from the Cheyenne portion of the control F1850 case

- 240K_D: namelists from the Derecho portion of the 24OK optics F1850 case
- 263K_D: namelists from Derecho for the 263K optics F1850 case
- 273K_D: namelists from the Derecho portion of the 273K optics F1850 case
- control_D: namelists from the Derecho portion of the control F1850 case

## Code files

- create_cesm_run_control_cheyenne.csh: shell file for creating and running the first 20 years of the control F1850 run on Cheyenne
- create_cesm_run_cri240K_cheyenne.csh: shell file for creating and running the first 20 years of the 240K optics F1850 run on Cheyenne
- create_cesm_run_cri273K_cheyenne.csh: shell file for creating and running the first 20 years of the 273K optics F1850 run on Cheyenne
  
- create_cesm_run_control_derecho.csh: shell file for creating and running the last 20 years of the control F1850 run on Derecho
- create_cesm_run_cri240K_derecho.csh: shell file for creating and running the last 20 years of the 240K optics F1850 run on Derecho
- create_cesm_run_cri263K_derecho.csh: shell file for creating and running all 40 years of the 263K optics F1850 run on Derecho
- create_cesm_run_cri273K_derecho.csh: shell file for creating and running the last 20 years of the 273K optics F1850 run on Derecho
