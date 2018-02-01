######################################
#             TFM 2016               #
#    Code: script_traffic_states.py  #
#    Autor: Xavier Ros Roca          #
######################################

trafficStateFile='C:\\Users\\xavier.ros.roca\\Desktop\\Others\\TFM\\02_Data\\traffic_state_data_flow_19_march.csv'
turnsFile='C:\\Users\\xavier.ros.roca\\Desktop\\Others\\TFM\\02_Data\\traffic_state_data_turns_19_march.csv'

def findSection( model, entry ):	
	section = model.getCatalog().find( int(entry) )
	if section.isA( "GKSection" ) == False:
		section = None
	return section

def getStateFolder( model ):
	folderName = "GKModel::trafficStates"
	folder = model.getCreateRootFolder().findFolder( folderName )
	if folder == None:
		folder = GKSystem.getSystem().createFolder( model.getCreateRootFolder(), folderName )
	return folder

def createState( model, name,fromTime,durationTime):
	state = GKSystem.getSystem().newObject( "GKTrafficState", model )
	state.setName( name )
	state.setFrom(QTime.fromString(fromTime, Qt.ISODate))
	state.setDuration(GKTimeDuration.fromString( durationTime))
	vehicle = model.getCatalog().find(53)
	state.setVehicle( vehicle )
	folder = getStateFolder( model )
	folder.append( state )
	return state

def setEntranceFlow(model,state,sectionName,flow):
	section=findSection(model,sectionName)
	state.setEntranceFlow(section,None,float(flow))

def setTurns(model,state,originName,destinationName,percentage):
	origin=findSection(model,originName)
	destination=findSection(model,destinationName)
	state.setTurningPercentage(origin,destination,None,float(percentage))

#First a dictionary with the turns info is created
dictTurns={}
for line in open(turnsFile,'r').readlines():
	tokens2=line.split(",")
	dictTurns[tokens2[0]] = line


for line in open( trafficStateFile, "r" ).readlines():
	tokens = line.split(",")
	state = createState( model, tokens[0],tokens[0],"0:05:00")
	setEntranceFlow(model,state,tokens[1],tokens[2])
	setEntranceFlow(model,state,tokens[3],tokens[4])
	setEntranceFlow(model,state,tokens[5],tokens[6])
	setEntranceFlow(model,state,tokens[7],tokens[8])

	turnsLine = dictTurns[tokens[0]]
	turns=turnsLine.split(",")
	setTurns(model,state,turns[1],turns[2],turns[3])
	setTurns(model,state,turns[4],turns[5],turns[6])
	setTurns(model,state,turns[7],turns[8],turns[9])
	setTurns(model,state,turns[10],turns[11],turns[12])
	setTurns(model,state,turns[13],turns[14],turns[15])
	setTurns(model,state,turns[16],turns[17],turns[18])
		
model.getCommander().addCommand( None )
print "Done"