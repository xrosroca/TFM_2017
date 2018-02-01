%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                  TFM 2016             %
%           Code: AIMSUN.m              %
%           Author: Xavier Ros Roca     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [y,t,assMatr, Ry, Rt]=AIMSUN(ODPattern,AIMSpath,OS,desOutputs,P)

	load scenarioInfo/Origins.txt;
	load scenarioInfo/Destinations.txt;
	load scenarioInfo/BT.txt;
	for j=1:size(ODPattern,2)
		
		m=reshape(ODPattern(:,j),length(Origins),length(Destinations));
		
		filename=strcat('m',num2str(j-1),'.txt');
		fid=fopen(filename,'w');
		fprintf(fid,'id\t');
		fprintf(fid,'%i\t',Destinations);
		fprintf(fid,'\n');
		fclose(fid);
		fid=fopen(filename,'a');
		for i=1:length(Origins)
			fprintf(fid,'%i\t',Origins(i));
			fprintf(fid,'%5.2f\t',m(i,:));
			fprintf(fid,'\n');
		end
		fclose(fid);
	end

	detecPath='scenarioInfo/detectors.txt';

	fid=fopen('scenarioInfo/scenario.txt');
	simData=textscan(fid,'%u %u %s %s %s %s');
	replID=simData{1,1};
	dbID=simData{1,2};
	DBname=cell2mat(simData{1,3});
	angName=cell2mat(simData{1,4});
	pyPath=cell2mat(simData{1,5});
	assMatrName=cell2mat(simData{1,6});

	if OS==1
		%For Windows Users
		parafile(P);
		commandTerminal= horzcat('"',AIMSpath,'" -script "',cd,'/',pyPath,'" "',cd,'/',angName,'" ',num2str(replID),' ',num2str(dbID));
		system(commandTerminal);
		fprintf('SIMULATION ENDED \n')
		
	else
		%For MAC/Unix Users
		commandTerminal= horzcat(AIMSpath,' -script ',cd,'/',pyPath,' ',cd,'/',angName,' ',num2str(replID),' ',num2str(dbID));
		fid = fopen('./batchAIMS.sh','w');
		fprintf(fid,'osascript -e ''tell application "Terminal"\n');
		fprintf(fid,'\t do script "%s"\n',commandTerminal);
		fprintf(fid,'end tell''\n');
		fclose(fid);
		!chmod 755 ./batchAIMS.sh
		!xattr -d com.apple.quarantine ./batchAIMS.sh
		system('./batchAIMS.sh');
		while exist('testnet.matrix','file')==0
		end
		fid = fopen('./batchAIMS.sh','w');
		fprintf(fid,'osascript -e ''tell application "Terminal" to quit''');
		fclose(fid);
		system('./batchAIMS.sh');
	end


	conn = sqlite(DBname);

	detecID=load(detecPath);
	sqlQuery='SELECT oid + 0.0 as oid2,  ent +0.0 as ent2, flow + 0.0 as flow2, speed + 0.0 as speed2, occupancy + 0.0 as occupancy2, density+0.0 as density2 FROM MIDETEC WHERE did = 10 and sid = 1 and ent <> 0 order by oid, ent;';
	sqlQuery2='SELECT oid + 0.0 as oid2, ent + 0.0 as ent2, ttime FROM MISECT WHERE did = 10 and sid = 1 and ent <> 0 order by oid, ent;';

	simTimes_all = [];
	for i = 1:length(BT)
		sqlQuery2 = horzcat('select A.oid + 0.0 as start_point, B.oid + 0.0 as end_point, A.idveh + 0.0 as idveh, A.timedet + 0.0 as time_ini, B.timedet + 0.0 as time_fin, B.timedet - A.timedet as ttime from (select * from DETEQUIPVEH where oid = ', num2str(BT(i,1)),  ' and did = 10) A inner join (select * from DETEQUIPVEH where oid = ', num2str(BT(i,2)), ' and did = 10) B on A.idveh = b.idveh');
		simTimes = cell2mat(fetch(conn, sqlQuery2));
		
		
		summ = 14400;
		
		for j = 1:length(simTimes)
			if simTimes(j,4) < 38100 + summ
				simTimes(j,7) = 1;
			elseif simTimes(j,4) < 38400 + summ
				simTimes(j,7) = 2;
			elseif simTimes(j,4) < 38700 + summ
				simTimes(j,7) = 3;
			elseif simTimes(j,4) < 39000 + summ
				simTimes(j,7) = 4;
			elseif simTimes(j,4) < 39300 + summ
				simTimes(j,7) = 5;
			elseif simTimes(j,4) < 39600 + summ
				simTimes(j,7) = 6;
			elseif simTimes(j,4) < 39900 + summ
				simTimes(j,7) = 7;
			elseif simTimes(j,4) < 40200 + summ
				simTimes(j,7) = 8;
			elseif simTimes(j,4) < 40500 + summ
				simTimes(j,7) = 9;
			elseif simTimes(j,4) < 40800 + summ
				simTimes(j,7) = 10;
			elseif simTimes(j,4) < 41100 + summ
				simTimes(j,7) = 11;
			else
				simTimes(j,7) = 12;
			end
		end
		simTimes_all = [simTimes_all;simTimes];
	end

	simTimes_DT = array2table(simTimes_all(:,[1, 2, 7, 6]), 'VariableNames', {'Start', 'End', 'Int', 'ttime'});

	simTimes = table2array(grpstats(simTimes_DT, {'Start', 'End', 'Int'}, {'min', 'max', 'mean', 'median'}));
	simTimes = sortrows(simTimes, [1, 2, 3]);




	out=cell2mat(fetch(conn, sqlQuery));
	outputs=[];
	for i=1:length(detecID)
		outputs=[outputs; out(find(out(:,1)==detecID(i)),:)];
	end

	cols = [1, 2 , find(desOutputs == 1)+2];
	simData = outputs(:, cols);

	simData(find(simData==-1))=0;

	load('scenarioInfo/trueData.txt');
	load('scenarioInfo/trueTimes.txt');


	assMatr=[];
	% GoF measures are evaluated for the travel times
	[t Rt] = fObjT(trueTimes,simTimes);


	% The 12 GoF measures are then evaluated on the desired outputs
	[y Ry] = (fObj(trueData,simData));


end