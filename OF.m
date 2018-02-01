%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                  TFM 2016             %
%           Code: OF.m                  %
%           Author: Xavier Ros Roca     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ of, R ] = OF( P , TRmin, TRmax)

	load data;
	desOut = [1,1,0,0]; % We want the GoF measured for FLOWS and SPEEDS
	AIMSpath = 'C:\Program Files\TSS-Transport Simulation Systems\Aimsun 8.1/aconsole.exe';

	[gofs,times,assMatr, Ry, Rt]=AIMSUN(ODPattern,AIMSpath,1,desOut,P);

	of1 = sum(gofs(:,3));
	of2 = mean(times(:,3));

	Pn = Normalize(P, TRmin, TRmax);

	of = (of1+of2) + 1/2*(sum(max(Pn-10,0).^2)  + 3*sum(min(Pn, 0).^2) + 3*max(P(7)-P(8), 0)^2);

	R = [Ry Rt];

end
