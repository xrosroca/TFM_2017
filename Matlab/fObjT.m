%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                  TFM 2016             %
%           Code: fObjT.m               %
%           Author: Xavier Ros Roca     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [t, R] =fObjT(trueMoP,allMoP)


	kk=size(trueMoP);

	trueMoP = trueMoP(:, 7);
	allMoP = allMoP(:, 7);

	kk=size(trueMoP);
	RMSE=[];
	SE=[];
	MAE=[];
	NRMSE =[];
	NMAE =[];
	U =[];
	ME = [];
	NME = [];
	RMSNE=zeros(1, kk(2));
	GEH1=zeros(1, kk(2));
	MANE=zeros(1, kk(2));
	MNE=zeros(1, kk(2));
	U1=[];
	U2=[];

	for i=1:kk(2)
		RMSE(i)=sqrt(sum(allMoP(:,i)-trueMoP(:,i)).^2/kk(1));
		SE(i)=sum(allMoP(:,i)-trueMoP(:,i)).^2;
		MAE(i)=sum(abs(allMoP(:,i)-trueMoP(:,i)))/kk(1);
		U1(i)=sqrt(sum((allMoP(:,i)).^2)/kk(1));
		U2(i)=sqrt(sum((trueMoP(:,i)).^2)/kk(1));
		U(:,i)=RMSE(i)/(U1(i)+U2(i));
		ME(i)=sum((allMoP(:,i)-trueMoP(:,i)))/(kk(1));
		NME(i)=(sum(allMoP(:,i)-trueMoP(:,i)))/(sum(trueMoP(:,i)));
		NRMSE(i)=100*sqrt(sum((allMoP(:,i)-trueMoP(:,i)).^2)/kk(1))/(max(trueMoP(:,i))-min(trueMoP(:,i)));
		NMAE(i)=sum(abs(allMoP(:,i)-trueMoP(:,i)))/(sum(abs(trueMoP(:,i))));
		
		
		
		for j=1:kk(1)
			if trueMoP(j,i)>0
				RMSNE(i)=RMSNE(i)+((allMoP(j,i)-trueMoP(j,i))/trueMoP(j,i))^2;
				MANE(i)=MANE(i)+abs((allMoP(j,i)-trueMoP(j,i))/trueMoP(j,i));
				MNE(i)=MNE(i)+(allMoP(j,i)-trueMoP(j,i))/trueMoP(j,i);
			elseif allMoP(j,i)>0
				RMSNE(i)=RMSNE(i)+1;
				MANE(i)=MANE(i)+1;
				MNE(i)=MNE(i)+1;
			end
			if trueMoP(j,i)>0 || allMoP(j,i)>0
				GEH=sqrt(2*(allMoP(j,i)-trueMoP(j,i))^2/(allMoP(j,i)+trueMoP(j,i)));
				if GEH<=1
					GEH1(i)=GEH1(i)+1;
				end
			else
				GEH1(i)=GEH1(i)+1;
			end
		end
		
		MNE(i)=MNE(i)/kk(1);
		RMSNE(i)=sqrt(RMSNE(:,i)/kk(1));
		MANE(i)=MANE(i)/kk(1);
		GEH1(i)=(kk(1)-GEH1(i))/kk(1);
	end
	R1 = corrcoef(trueMoP(:,1),allMoP(:,1));

	R = R1(1,2);

	t=[RMSE;RMSNE;NRMSE;GEH1;MAE;MANE;NMAE;SE;U;ME;MNE;NME]';

end