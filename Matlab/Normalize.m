%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                  TFM 2016             %
%           Code: Normalize.m           %
%           Author: Xavier Ros Roca     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function  Pn  = Normalize( P , TRmin, TRmax)

	Pn = 10*(P-TRmin)./(TRmax-TRmin);

end
