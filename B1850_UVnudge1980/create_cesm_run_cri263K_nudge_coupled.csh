#!/bin/csh -fv

#*****************************************************************
# Create, setup, build, & run CESM2 case
#
# Usage:
#	./create_cesm_run_cri263K_nudge_coupled.csh
#****************************************************************

## Set option variables in this section
# Set case parameters & name
set CASETITLE=cri263K_test_nudge
set RES=f09_g17
set COMPSET=B1850
set COMPSET_SHORT=b

set REFCASE=${COMPSET_SHORT}.e21.${COMPSET}.${RES}.CMIP6-piControl.001_branch2

set PROJ=$PROJECT
echo $PROJ
set CONT_RUN=TRUE

## Set path variables in this section
set CESMDIR=/glade/work/glydia/cesm2.2.0
set MODSDIR=/glade/u/home/glydia/mods

# Set array variables for looping through ensemble members
set NNN_arr=( 001 002 003 004 005 006 007 008 009 010 )
set ptlm_arr=( 0 1.0e-14 2.0e-14 3.0e-14 4.0e-14 5.0e-14 6.0e-14 7.0e-14 8.0e-14 9.0e-14 )

## Loop through all ensemble members
foreach i ( 1 2 3 4 5 6 7 8 9 10 )
	## Set option variables specific to ensemble member
	# Set ensemble number case name
	set NNN=$NNN_arr[$i]
	set CASENAME=${COMPSET_SHORT}.e22.${COMPSET}.${RES}.${CASETITLE}.${NNN}
	echo $CASENAME

	# Set case path variable
	set CASEDIR=/glade/u/home/glydia/cases/$CASENAME

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

		# Runtime variables
		./xmlchange STOP_OPTION="nyears",RESUBMIT=0,STOP_N=1,JOB_WALLCLOCK_TIME=5:00:00,REST_N=1,REST_OPTION="nyears",CONTINUE_RUN=$CONT_RUN
		./xmlquery STOP_OPTION,RESUBMIT,STOP_N,JOB_WALLCLOCK_TIME,REST_N,REST_OPTION,CONTINUE_RUN

		# Any other xmlchanges...
		./xmlchange RUN_TYPE=hybrid,RUN_REFCASE=$REFCASE,RUN_REFDATE=1011-01-01,GET_REFCASE=FALSE,CLM_NAMELIST_OPTS=''
		./xmlquery RUN_TYPE,RUN_REFCASE,RUN_REFDATE

		## Setup case
		./case.setup

		# Copy source mods - if any
		#cp $MODSDIR/* $CASEDIR/SourceMods/src.cam/

		# Copy restart files
		cp /glade/campaign/cgd/ppc/cesm2_tuned_albedo/$REFCASE/rest/1011-01-01-00000/* /glade/scratch/$USER/$CASENAME/run/

		## Do NAMELIST modifications here
		cat >> user_nl_cam <<  EOFcam
nhtfrq = 0,-24
mfilt = 1,30
empty_htapes = .true.
fincl1 = 'CLDLIQ','CLDICE','T','CLOUD','IWC','LWC','EMIS','TOT_CLD_VISTAU','TS','TGCLDCWP','TGCLDLWP','TGCLDIWP','FLDS','FSDS','LWCF','SWCF','PRECL','PRECSL','FLUT','FSUTOA','U','V','Target_U','Target_V'
fincl2 = 'CLDLIQ','CLDICE','T','CLOUD','TS','TGCLDLWP','TGCLDIWP','FLDS','FSDS','FLUT','FSUTOA','U','V','Target_U','Target_V','Target_T'
liqopticsfile = "/glade/work/glydia/Liquid_optics_files/CESM_CRI_RFN_263K.nc"
inithist = 'MONTHLY'
Nudge_Model = .true.
Nudge_Path = '/glade/scratch/glydia/inputdata/nudging/ERAI_fv09/'
Nudge_File_Template = 'ERAI_fv09.cam2.i.%y-%m-%d-%s.nc'
Nudge_Force_Opt = 1
Nudge_Times_Per_Day = 4
Model_Times_Per_Day = 48
Nudge_Uprof  =2
Nudge_Ucoef  =1.0
Nudge_Vprof  =2
Nudge_Vcoef  =1.0
Nudge_Tprof  =0
Nudge_Tcoef  =1.00
Nudge_Qprof  =0
Nudge_Qcoef  =1.00
Nudge_PSprof =0
Nudge_PScoef =1.00
Nudge_Beg_Year =0001
Nudge_Beg_Month=01
Nudge_Beg_Day  =01
Nudge_End_Year =0001
Nudge_End_Month=12
Nudge_End_Day  =31
Nudge_Hwin_lat0    = 75.0
Nudge_Hwin_latWidth=15.0
Nudge_Hwin_latDelta=3.0
Nudge_Hwin_lon0    =180.
Nudge_Hwin_lonWidth=999.
Nudge_Hwin_lonDelta=1.0
Nudge_Vwin_Hindex  =24.
Nudge_Vwin_Hdelta  =0.1
Nudge_Vwin_Lindex  =0.
Nudge_Vwin_Ldelta  =0.1
EOFcam

		cat >> user_nl_clm << EOFclm
EOFclm

	
		## If not the 1st ensemble member, then set pertlim value
		if ($i > 1) then
			set ptlm=$ptlm_arr[$i]
			echo $ptlm

			# Do additional NAMELIST modifications
			cat >> user_nl_cam << EOFcam
pertlim = $ptlm
EOFcam

		endif

		./preview_namelists

		## Build case
		qcmd -- ./case.build

		## Submit case to queue
		./case.submit

	endif

	## If CONTINUE_RUN is true
	if ($CONT_RUN == TRUE) then
		cd $CASEDIR

		# Do XMLCHANGE options for CONTINUE_RUN - 3 months
		./xmlquery STOP_N,STOP_OPTION,RESUBMIT,REST_N,CONTINUE_RUN
		./xmlchange STOP_N=3,STOP_OPTION="nmonths",RESUBMIT=0,REST_N=3,REST_OPTION="nmonths",CONTINUE_RUN=$CONT_RUN
		./xmlquery STOP_N,STOP_OPTION,RESUBMIT,REST_N,REST_OPTION,CONTINUE_RUN

		cat >> user_nl_cam <<  EOFcam
Nudge_Beg_Year =0001
Nudge_Beg_Month=01
Nudge_Beg_Day  =01
Nudge_End_Year =0002
Nudge_End_Month=03
Nudge_End_Day  =31
EOFcam

		./preview_namelists

		./case.submit

	endif
end
