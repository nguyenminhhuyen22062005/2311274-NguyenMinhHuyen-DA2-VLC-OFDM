function [bOpt, sReq] = optimum_bias(o, target, grid)
% OPTIMUM_BIAS  Tim DC bias (dB) cho DCO-OFDM lam Eb/N0 yeu cau nho nhat tai
% BER = target (dung mo hinh giai tich ber_theory).
if nargin < 3, grid = 3:0.25:16; end
s = nan(size(grid));
for i = 1:numel(grid)
    o.biasdB = grid(i);
    s(i) = required_snr_theory('dco', target, o);
end
[sReq, i] = min(s);
bOpt = grid(i);
end
