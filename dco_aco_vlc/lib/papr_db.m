function p = papr_db(y)
% PAPR_DB  PAPR (dB) cua tung cot (moi cot = 1 ky hieu OFDM):
%   PAPR = max |y|^2 / E[|y|^2]
p = 10*log10(max(y.^2, [], 1) ./ mean(y.^2, 1));
end
