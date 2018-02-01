%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                  TFM 2016             %
%           Code: SPSA.m                %
%           Author: Xavier Ros Roca     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ Pk, ofval] = SPSA( e, M , TRbool, seed)

	rng(seed);
	fileID = fopen('R.txt','w');
	% fprintf(fileID, datestr(now,'dd-mm-yyyy HH:MM:SS'));
	fprintf(fileID,'');
	fclose(fileID);

	fileID = fopen('P.txt','w');
	% fprintf(fileID, datestr(now,'dd-mm-yyyy HH:MM:SS'));
	fprintf(fileID,'');
	fclose(fileID);

	fileID = fopen('ofval.txt','w');
	% fprintf(fileID, datestr(now,'dd-mm-yyyy HH:MM:SS'));
	fprintf(fileID,'');
	fclose(fileID);

	fprintf('SPSA execution \n\n');
	fprintf('Max Iterations: %d \n', M);
	fprintf('Relative Error: %d \n', e);
	fprintf('TrustRegion = %d\n', TRbool);


	TRmin = [85,   2,  0.7,  0.2,    0.6,  0.3,  0.5, 0.7,  2,   1,   0.2,     0.2];
	TRmax = [120, 10,  1.4,  1.0,    2.0,  1.0,  1.8,  2.2,   10,  4,   1.5, 0.8];

	Pk = (3*TRmax+2*TRmin)/5 ;

	k = 0;
	stop = 0;

	a = 2.2;
	A = 6;
	alfa = 0.602;


	c =  0.6;
	gamma = 0.101;

	r = 1;

	ofval = [];

	fileID = fopen('logfile.txt','w');
	fprintf(fileID, datestr(now,'dd-mm-yyyy HH:MM:SS'));
	fprintf(fileID, '\n');
	fprintf(fileID, 'Values of parameters: a = %f, c = %f, A = %d, r = %f', a, c, A, r);
	fprintf(fileID, '\nTRmin:\n');
	fprintf(fileID, '%f\t', TRmin);
	fprintf(fileID, '\nTRmax:\n');
	fprintf(fileID, '%f\t', TRmax);
	fprintf(fileID, '\n');
	fprintf(fileID, 'seed = %d\n', seed);
	fclose(fileID);

	while stop == 0
		k = k + 1;
		fprintf('--------------------------------------------------------\n');
		fprintf(datestr(now,'dd-mm-yyyy HH:MM:SS'));
		fprintf('\n');
		fprintf('Iteration: %d \n', k);
		
		fileID_P = fopen('P.txt','a');
		fprintf(fileID_P, '%f\t',Pk);
		fprintf(fileID_P, '\n');
		fclose(fileID_P);
		
		ck = c/(k+1)^gamma;
		
		Vk = (2*round(rand(12,1))-1)'; % Bernoulli. 1 or -1. Random direction.
		
		Pnk = Normalize(Pk, TRmin, TRmax);
		
		
		Pnka = Pnk + ck*Vk;
		
		Pka = InvNormalize(Pnka, TRmin, TRmax);
		Pka  = TR(Pka, TRmin, TRmax, TRbool);
		
		
		fprintf('FIRST SIMULATION STARTING... \n')
		[ofb Rb]= OF(Pk, TRmin, TRmax);
		
		fprintf('SECOND SIMULATION STARTING... \n')
		[ofa Ra] = OF(Pka, TRmin, TRmax);
		ofa
		ofb
		
		
		ofval = [ofval,ofb];
		
		
		R = Rb;
		
		
		fileID_R = fopen('R.txt','a');
		fprintf(fileID_R, '%f\t',R);
		fprintf(fileID_R, '\n');
		fclose(fileID_R);
		
		Rb = mean(Rb);
		
		fprintf('Mean of Correlations: %f\n', Rb );
		fprintf('Objective function value: %f\n', ofb);
		
		Gk = (ofa - ofb)./(ck*Vk);
		
		rk = r/(k^0.1);
		
		ak = a/(A+k+1)^alfa;
		
		Pnkk = Pnk - ak.*Gk  - ak*rk.*(max(Pnk-10,0)  + 3*min(Pnk, 0) +  3*max(Pk(7)-Pk(8), 0)*[0 0 0 0 0 0 +1 -1 0 0 0 0]);
		
		
		Pkk = InvNormalize(Pnkk, TRmin, TRmax);
		Pkk = TR(Pkk, TRmin, TRmax, TRbool);
		
		rel_grad = norm(Pnk - Pnkk)/norm(Pnkk);
		fprintf('Relative Error Gradient: %f\n', rel_grad);
		fprintf('--------------------------------------------------------\n')
		
		if rel_grad < e  % Rel. diff. is small enough to stop
			stop = 1;
		elseif k > M - 1
			stop = 2;
			fprintf('The algorithm did not converge in  %d  steps.\n', M);
		end
		
		Pk = Pkk;
		
		
		
		fileID_of = fopen('ofval.txt','a');
		fprintf(fileID_of, '%f\n',ofb);
		fclose(fileID_of);
		
		logfile(k, R, ofb, Pk, Gk, rel_grad);
		
	end


	er = norm(Pk - Pkk)/norm(Pkk);


	resultsfile(k,stop,ofval,Pk,Gk, er);    % Printing the results in a .txt file

end
