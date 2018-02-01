%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                  TFM 2016             %
%           Code: InvNormalize.m        %
%           Author: Xavier Ros Roca     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  P  = InvNormalize( Pn , TRmin, TRmax)

	P = TRmin + Pn.*(TRmax-TRmin)/10;

end