function [idx, Nd] = ofdm_subcarriers(scheme, N)
% OFDM_SUBCARRIERS  Chi so (MATLAB, 1-based) cac song mang du lieu.
%   DCO-OFDM: k = 1 .. N/2-1          -> Nd = N/2 - 1
%   ACO-OFDM: k = 1, 3, 5, .., N/2-1  -> Nd = N/4  (chi song mang le)
% Nua con lai (k = N/2+1 .. N-1) la lien hop doi xung Hermitian.
switch lower(scheme)
    case 'dco'
        k = 1:(N/2-1);
    case 'aco'
        k = 1:2:(N/2-1);
    otherwise
        error('scheme phai la ''dco'' hoac ''aco''');
end
idx = k + 1;
Nd  = numel(k);
end
