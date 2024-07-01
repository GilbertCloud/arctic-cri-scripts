#!/bin/csh -fv

#*****************************************************************
# Create, setup, build, & run CESM2 case
#
# Usage:
#	./create_cesm_run_cri240K.csh
#****************************************************************

## Set option variables in this section
# Set case parameters & name
set CASETITLE=cri273K_test
set RES=f09_f09_mg17
set COMPSET=F1850
set COMPSET_SHORT=f
set NNN=003

set CASENAME=${COMPSET_SHORT}.e22.${COMPSET}.${RES}.${CASETITLE}.${NNN}
set REFCASE=${COMPSET_SHORT}.e22.${COMPSET}.${RES}.${CASETITLE}.002

set PROJ=$PROJECT

echo $PROJ
echo $CASENAME
set CONT_RUN=FALSE

## Set path variables in this section
set CESMDIR=/glade/work/glydia/cesm2.2_derecho
set CASEDIR=/glade/u/home/glydia/derecho_cases/$CASENAME
set MODSDIR=/glade/u/home/glydia/mods

## If CONTINUE_RUN is false
if ($CONT_RUN == FALSE) then
	## Create case
	cd $CESMDIR/cime/scripts

	./create_newcase --case $CASEDIR --res $RES --compset $COMPSET --project $PROJ --run-unsupported

	cd $CASEDIR

	## Do XMLCHANGE options here

	# CAM configure options
	#./xmlchange --append CAM_CONFIG_OPTS='cosp'

	# Debug
	#./xmlchange INFO_DBUG=2
	#cp $MODSDIR/env_mach_pes.xml .

	# Runtime variables
	./xmlchange STOP_OPTION="nyears",RESUBMIT=0,STOP_N=4,JOB_WALLCLOCK_TIME=11:57:00,REST_N=2,REST_OPTION="nyears",CONTINUE_RUN=$CONT_RUN
	./xmlquery STOP_OPTION,RESUBMIT,STOP_N,JOB_WALLCLOCK_TIME,REST_N,REST_OPTION,CONTINUE_RUN

	# Any other xmlchanges...
	./xmlchange RUN_TYPE=hybrid,RUN_REFCASE=$REFCASE,RUN_REFDATE=0021-01-01,GET_REFCASE=FALSE,CLM_NAMELIST_OPTS=''
	./xmlquery RUN_TYPE,RUN_REFCASE,RUN_REFDATE

	## Setup case
	./case.setup

	# Copy source mods - if any
	#cp $MODSDIR/* $CASEDIR/SourceMods/src.cam/

	# Copy restart files
	cp /glade/derecho/scratch/$USER/archive/$REFCASE/rest/0021-01-01-00000/* /glade/derecho/scratch/$USER/$CASENAME/run/

	## Do NAMELIST modifications here
	cat >> user_nl_cam <<  EOFcam
nhtfrq = 0
mfilt = 1
empty_htapes = .true.
fincl1 = 'CLDLIQ','CLDICE','T','CLOUD','CDNUMC','AQSNOW','ANSNOW','IWC','LWC','EMIS','TOT_CLD_VISTAU','FICE','TS','ADRAIN','ADSNOW','ANRAIN','AREI','AREL','AWNC','AWNI','TGCLDCWP','TGCLDLWP','TGCLDIWP','FLDS','FSDS','LWCF','SWCF','PRECL','PRECSL','FLUT','FSUTOA','QRL','QRS','FLNS','FLNSC','FLNT','FLNTC','FLNR','FLUTC','FSDSC','FSNS','FSNSC','FSNT','FSNTC','FSNTOA','FSNTOAC'
liqopticsfile = "/glade/work/glydia/Liquid_optics_files/CESM_CRI_RFN_273K.nc"
EOFcam

	cat >> user_nl_clm << EOFclm
EOFclm

	./preview_namelists

	## Build case
	qcmd -- ./case.build

	## Submit case to queue
	./case.submit

endif

## If CONTINUE_RUN is true
if ($CONT_RUN == TRUE) then
	cd $CASEDIR

	# Do XMLCHANGE options for CONTINUE_RUN
	./xmlquery JOB_QUEUE,JOB_WALLCLOCK_TIME
	./xmlchange JOB_QUEUE="regular",JOB_WALLCLOCK_TIME=11:57:00
	./xmlquery JOB_QUEUE,JOB_WALLCLOCK_TIME
		
	# Do XMLCHANGE options for CONTINUE_RUN - 16 years
	./xmlquery STOP_N,STOP_OPTION,RESUBMIT,REST_N,CONTINUE_RUN
	./xmlchange STOP_N=4,STOP_OPTION="nyears",RESUBMIT=3,REST_N=2,REST_OPTION="nyears",CONTINUE_RUN=$CONT_RUN
	./xmlquery STOP_N,STOP_OPTION,RESUBMIT,REST_N,REST_OPTION,CONTINUE_RUN

	./case.submit

endif



