function T = exp6_bias_sweep(Ms, maxBits)
%EXP6_BIAS_SWEEP  Quet DC bias bang mo phong quanh muc toi uu theo giai tich.
%   T = exp6_bias_sweep             chay M = 4, 16, 64
%   T = exp6_bias_sweep(16)         chi chay 16-QAM
%   T = exp6_bias_sweep(Ms, maxBits) so bit toi da moi diem SNR, mac dinh 1e7
%
% Exp5 chon bias cua DCO-OFDM bang mo hinh giai tich (optimum_bias) roi chi
% mo phong tai dung muc do. Script nay kiem tra lai: voi moi bac dieu che M,
% mo phong Monte Carlo SNR yeu cau tai BER 1e-3 o cac muc bias
% tu b0 - 1 den b0 + 2 dB, buoc 0.5 dB (b0 la bias toi uu giai tich),
% tu do tim bias tot nhat theo mo phong.
%
% Ket qua: results/exp6_bias_sweep.csv; ve hinh r14_bias_sweep bang make_figures.
if nargin < 1, Ms = [4 16 64]; end
if nargin < 2, maxBits = 1e7; end
cfg = init_sim();
T = [];
for M = Ms
    T = [T; sweep_one(M, maxBits, cfg)];
end
hdr = {'M', 'biasdB', 'offset_from_analytic', 'req_elec_th', 'req_elec_sim', 'sim_minus_th'};
write_csv(fullfile(cfg.resDir, 'exp6_bias_sweep.csv'), hdr, T);
end

function rows = sweep_one(M, maxBits, cfg)
try, rng(cfg.seed + M); catch, rand('state', cfg.seed + M); randn('state', cfg.seed + M); end
fprintf('\n===== EXP6: quet bias bang mo phong, DCO %d-QAM =====\n', M);
t0 = tic;
o = default_opt(); o.M = M; o.maxBits = maxBits; o.verbose = false; o.minBER = 1e-4;
b0 = optimum_bias(o, cfg.target);
biases = b0 + (-1:0.5:2);
rows = zeros(numel(biases), 6);
for i = 1:numel(biases)
    o.biasdB = biases(i);
    st = required_snr_theory('dco', cfg.target, o);
    sgrid = floor(st) - 2 : 0.5 : ceil(st) + 4;
    r = sim_link('dco', sgrid, o);
    ss = required_snr(sgrid, r.ber, cfg.target);
    rows(i, :) = [M, biases(i), biases(i) - b0, st, ss, ss - st];
    fprintf('  bias %5.2f dB: SNR yeu cau giai tich %6.2f dB, mo phong %6.2f dB\n', biases(i), st, ss);
end
[~, k] = min(rows(:, 5));
if k == 1 || k == numel(biases)
    fprintf('  Chu y: muc tot nhat nam o bien vung quet, nen mo rong vung quet.\n');
end
fprintf('  Bias tot nhat theo giai tich %.2f dB, theo mo phong %.2f dB (SNR %.2f dB); %.1f phut\n', ...
    b0, rows(k, 2), rows(k, 5), toc(t0) / 60);
end
