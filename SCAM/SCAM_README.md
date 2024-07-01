# SCAM

SCAM was run on a local machine following these instructions: [SCAM_Startup](https://ftp.cgd.ucar.edu/archive/cam-tutorial/SCAM-Practical/SCAM_Startup.pdf)

## Directories

- 240K: namelists for the 240K MPACE SCAM run
- 263K: namelists for the 263K MPACE SCAM run
- 273K: namelists for the 273K MPACE SCAM run
- control: namelists for the control MPACE SCAM run
- code_mods: CESM code modifications for SCAM, enabling the saving of spectral fluxes

## Code files

- create_scam6_iop_control: creates and runs the MPACE SCAM control case
- create_scam6_iop_rfn: creates and runs the MPACE temperature-dependent optics SCAM cases. The optics temperature is changed using the variable 'OPT_TEMP'
