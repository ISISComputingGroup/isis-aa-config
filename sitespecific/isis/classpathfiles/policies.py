#!/usr/bin/python

# policies.py
#
# Author:  M. Shankar, Jan 31, 2012
# Modification History
#        Jan 31, 2012, Shankar: Initial version of policies.py with comments.
#        May 14, 2012, Li, Shankar: Added support for archiving extra fields into policy file.
#		 Oct 15, 2024, Jack Doughty: Changed policies for use at ISIS/IBEX Archive Appliance
#
# This is the policies.py used to enforce policies for archiving PVs
# At a very high level, when users request PVs to be archived, the mgmt web app samples the PV to determine event rate and other parameters.
# In addition, various fields of the PV like .NAME, .ADEL, .MDEL, .RTYP etc are also obtained
# These are passed to this python script as a dictionary argument to a method called determinePolicy
# The variable name in the python environment for this information is 'pvInfo' (so use other variable names etc.).
# The method is expected to use this information to make decisions on various archiving parameters. 
# The result is expected to be another dictionary that is placed into the variable called "pvPolicy".
# Optionally, fields in addition to the VAL field that are to be archived with the PV are passed in as a property of pvPolicy called 'archiveFields'
# If the user overrides the policy, this is communicated in the pvinfo as a property called 'policyName'
#
# In addition, this script must communicate the list of available policies to the JVM as another method called getPolicyList which takes no arguments.
# The results of this method is placed into a variable called called 'pvPolicies'.  
# The dictionary is a name to description mapping - the description is used in the UI; the name is what is communicated to determinePolicy as a user override
#
# In addition, this script must communicate the list of fields that are to be archived as part of the stream in a method called getFieldsArchivedAsPartOfStream.
# The results of this method is placed into a list variable called called 'pvStandardFields'.  


# Generate a list of policy names. This is used to feed the dropdown in the UI.
def getPolicyList():
	pvPoliciesDict = {}
	pvPoliciesDict['Default'] = 'The default policy'
	return pvPoliciesDict

# Define a list of fields that will be archived as part of every PV.
# The data for these fields will included in the stream for the PV.
# We also make an assumption that the data type for these fields is the same as that of the .VAL field
def getFieldsArchivedAsPartOfStream():
	return ['HIHI','HIGH','LOW','LOLO','LOPR','HOPR','DRVH','DRVL']

samplePeriod = 1.0 

# We use the environment variables ARCHAPPL_SHORT_TERM_FOLDER and ARCHAPPL_MEDIUM_TERM_FOLDER to determine the location of the STS and the MTS in the appliance
shorttermstore_plugin_url = 'pb://localhost?name=STS&rootFolder=${ARCHAPPL_SHORT_TERM_FOLDER}&partitionGranularity=PARTITION_HOUR&hold=1&gather=1'
# 1 hour short term

mediumtermstore_plugin_url = 'pb://localhost?name=MTS&rootFolder=${ARCHAPPL_MEDIUM_TERM_FOLDER}&partitionGranularity=PARTITION_HOUR&hold=4416&gather=1'
# Minimum 6 months medium term.
# Max number of hours in 6 months is 4416.

longtermstore_plugin_url = 'pb://localhost?name=LTS&rootFolder=${ARCHAPPL_LONG_TERM_FOLDER}&partitionGranularity=PARTITION_YEAR&hold=999&pp=optimLastSample_10540800'# + str(8784 * 60 * 60 * (samplePeriod / 3))
# Minimum 10 years long term
# Max number of hours in 12 months is 8784.
# Downsamples by a third

def determinePolicy(pvInfoDict):

	pvPolicyDict = {}
	
	userPolicyOverride = ''
	if 'policyName' in pvInfoDict:
		userPolicyOverride = pvInfoDict['policyName']

	if userPolicyOverride == 'Default' or userPolicyOverride == '':

		pvPolicyDict['samplingPeriod'] = samplePeriod
		pvPolicyDict['samplingMethod'] = 'MONITOR'

		pvPolicyDict['dataStores'] = [
			shorttermstore_plugin_url, 
			mediumtermstore_plugin_url, 
			longtermstore_plugin_url
		]

	archiveFields=[]
	
	if "RTYP" in pvInfoDict:
		pvRTYP=pvInfoDict["RTYP"]
		if pvRTYP=="motor":
			archiveFields=[

				#"EGU",

				# Drive
				"RBV",
				"DRBV",
				"RRBV",
				"DVAL",
				"RVAL",
				"HLM",
				"DHLM",
				"HLS",
				"SPMG",
				"LLM",
				"DLLM",
				"LLS",
				"RLV",
				"JOGR",
				"JOGF",
				"TWR",
				"TWV",
				"TWF",
				"HOMR",
				"HOMF",
				"STOP",

				# Resolution
				"MRES",
				"ERES",
				"RRES",
				"RDBD",
				"RCNT",
				"RTRY",
				"UEIP",
				"URIP",
				"DLY",
				#"RDBL",
				#"PREM",
				#"POST",
				
				# Calibration
				"FOFF",
				"SET",
				"OFF",
				"DIR",
				
				# Dynamics
				"VMAX",
				"JVEL",
				"VELO",
				"BVEL",
				"VBAS",
				"ACCL",
				"BACC",
				"JAR",
				"BDST",
				"FRAC",

				#Status
				"STAT",
				"TDIR",
				"MOVN",
				"ATHM",
				"RMP",
				"REP",
				"MIP",
				"DIFF",
				"VERS",
				"CARD",
				"PREC",
				"CNEN",
				#"FLNK",

				# Servo
				"PCOF",
				"ICOF",
				"DCOF"

				]
			
		pvPolicyDict["archiveFields"]=archiveFields

	return pvPolicyDict
