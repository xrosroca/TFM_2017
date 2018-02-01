################################
#             TFM 2016         #
#    Code: odSimExecutor3.py   #
#    Author: Xavier Ros Roca    #
################################

import sys
import os
import time

from PyANGBasic import *
from PyANGKernel import *
from PyANGConsole import *
from PyANGAimsun import *
from PyMesoPlugin import *

def simulateMeso(model, rep, assignMatrixFileName):
    global fileLog
    experiment = rep.getExperiment()
    fileLog.write("Simulating meso experiment %s...\n" % experiment.getName())
    fileLog.flush()
    plugin = GKSystem.getSystem().getPlugin( "AMesoPlugin" ) # AMesoPlugin
    simulator=AMesoDTASimulator()  # AMesoDTASimulator  
    simulator.setModel( model )
    
    task=GKSimulationTask()
    task.replication=rep
    if experiment.getEngineMode()==GKExperiment.eOneShot:
        task.mode=GKReplication.eBatch
    else:
        task.mode=GKReplication.eBatchIterative
    simulator.addSimulationTask( task )         
    # simulator.setGatherProportions(True, assignMatrixFileName)
    simulator.simulate()                    
            
def simulateMicro(model, rep, assignMatrixFileName):
    plugin = GKSystem.getSystem().getPlugin("GGetram")
    simulator = plugin.getCreateSimulator(model)
    if not simulator.isBusy():
        if rep is not None and rep.isA("GKReplication"):
            if rep.getExperiment().getSimulatorEngine() == GKExperiment.eMicro:
                simulator.addSimulationTask(GKSimulationTask(rep, GKReplication.eBatch))
                simulator.simulate()
    
            
def main(argv):
    global fileLog
    
    if len(argv) != 4:
        print "Usage: aconsole -script %s ANG_FILE_NAME ID_REP ID_DATABASE" % argv[0]
        return -1

    angFileName = argv[1]
        
        
    params = []
    with open('C:\\Users\\xavier.ros.roca\\Desktop\\Others\\TFM\\05_Models\\Calibration\\parameters.txt', 'r') as file:
        for line in file:
            params = [float(val) for val in line.strip().split(' ')]

    #print params ####
    angAbsName = os.path.basename(angFileName)
    angName = os.path.splitext(angAbsName)[0]
    fileLogPath = os.path.dirname(angFileName) + os.sep+angName+'.log'

    
    assignMatrixFileName = os.path.dirname(angFileName) +os.sep+angName+'.matrix'
    
    if not os.path.exists(fileLogPath):
        fileLog = open( fileLogPath, "w" )
    else:
        fileLog = open( fileLogPath, "a" )
    
    idRep = int(argv[2])
    idDatabase = int(argv[3])

    system=GKSystem()
    
    fileLog.write("\noooooooooooooooooooooooooooooooooooooooooooooooooo\n" ) 
    fileLog.write("Date: %s - " % time.asctime( time.localtime(time.time()) ) )
    fileLog.write("%s - CONSOLE - " % str(system.getAppVersion()) )
    fileLog.write("ANG FILE: %s\n" %str(angFileName) )
    fileLog.write("Id Replication/Result: %d\n" %idRep )
    fileLog.write("Id Database: %d\n" %idDatabase )
    fileLog.write("Assignment Matrix file: %s\n" %assignMatrixFileName )
    fileLog.write("\noooooooooooooooooooooooooooooooooooooooooooooooooo\n" ) 
    
    # Start a Console
    console = ANGConsole()
    
    fileLog.flush()
    
    # Load a network
    if console.open(angFileName):
        # Create a backup
        console.save(angFileName+".old")
        console.save(angFileName)
        model=console.getModel()
                                
        fileLog.write( "--------------------------------------------\n")
        
        fileLog.write( "Network: %s \n" % str(model.getDocumentFileName()) )
        fileLog.write( "--------------------------------------------\n")
        fileLog.flush()
        
        vehicleType = model.getType("GKVehicle") ####
        carVeh = model.getCatalog().find(53) ####

        carVeh.setDataValueDouble(vehicleType.getColumn("GKVehicle::maxSpeedMean ", 1), params[0])
        carVeh.setDataValueDouble(vehicleType.getColumn("GKVehicle::maxSpeedDev", 1), params[1])
        carVeh.setDataValueDouble(vehicleType.getColumn("GKVehicle::speedAcceptanceMean", 1), params[2])
        carVeh.setDataValueDouble(vehicleType.getColumn("GKVehicle::speedAcceptanceDev", 1), params[3])
        carVeh.setDataValueDouble(vehicleType.getColumn("GKVehicle::minDistMean", 1), params[4])
        carVeh.setDataValueDouble(vehicleType.getColumn("GKVehicle::minDistDev", 1), params[5])
        reactionTimes = carVeh.getVariableReactionTimes()[0]
        reactionTimes.reactionTime = params[6]
        reactionTimes.reactionTimeAtStop = params[7]
        carVeh.setDataValueDouble(vehicleType.getColumn("GKVehicle::overtakingMarginMean", 1), params[8])
        carVeh.setDataValueDouble(vehicleType.getColumn("GKVehicle::overtakingMarginDev", 1), params[9])
        carVeh.setDataValueDouble(vehicleType.getColumn("GKVehicle::minimunHeadwayMean", 1), params[10])
        carVeh.setDataValueDouble(vehicleType.getColumn("GKVehicle::minimunHeadwayDev", 1), params[11])

        replication = model.getCatalog().find(idRep);
        if replication!=None and (replication.isA('GKReplication') or replication.isA('GKExperimentResult')):
            replication.setDBId(idDatabase)
            simulateMicro(model, replication, assignMatrixFileName)

            fileLog.write( "Simulation Finished at %s\n"%time.asctime( time.localtime(time.time()) ))
            fileLog.flush()             
        else:
            fileLog.write( "Cannot find the replication % d\n"%idRep)
            fileLog.flush()     
            fileLog.write( "Cannot1")
        network = model.getDocumentFileName()  ####
        #console.save(network[:-4]+"_tmp.ang")
           
        console.close()
    else:
        fileLog.write( "Cannot load the network\n")
        fileLog.flush()
        console.getLog().addError( "Cannot load the network" )   

        
        
try:
    sys.exit(main(sys.argv))
except:
    import traceback
    traceback.print_exc()