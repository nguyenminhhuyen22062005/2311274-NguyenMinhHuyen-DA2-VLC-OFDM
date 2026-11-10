function [ber, info] = ber_theory(scheme, EbN0dB, opt)
% BER_THEORY  BER giai tich cho DCO/ACO-OFDM: kenh AWGN + LED thong thap (can
% bang ZF, gia su CP du dai -> khong ISI) + nhieu xen theo dinh ly Bussgang.
%   SNR hieu dung tren song mang k:
%       gamma_k = K^2 / ( varD_bin + sigma_n^2 / |H_k|^2 )
%   DCO: K = Q(-mu) - Q(lt), varD_bin = sigma^2 * varD (nhieu xen trai deu N bin)
%   ACO: song mang le chi thay phan le clip(x,-T,T)/2 =>
%        K = (1 - 2Q(T/sigma))/2, varD_bin = 2 * sigma^2 * varD(-T,T) / 4
%        (khong xen tren -> K = 1/2, varD = 0: khong co meo tren song mang le)
if nargin < 3, opt = struct(); end
d = default_opt(); f = fieldnames(d);
for i = 1:numel(f), if ~isfield(opt, f{i}), opt.(f{i}) = d.(f{i}); end, end
N = opt.N; M = opt.M; k = log2(M);
[idx, Nd] = ofdm_subcarriers(scheme, N);
nb = Nd * k;
sigma = sqrt(2*Nd/N);
[~, ~, H] = led_lowpass(opt.beta, N);
H2 = abs(H(idx)).^2;
T = opt.clipTop;
if strcmpi(scheme, 'dco')
    mu = sqrt(10^(opt.biasdB/10) - 1);
    B = mu * sigma;
    [K, vD] = clipping_noise_var(-mu, (T - B)/sigma);
    varDbin = sigma^2 * vD;
else
    B = 0;
    if isinf(T)
        K = 0.5; varDbin = 0;
    else
        [Ks, vD] = clipping_noise_var(-T/sigma, T/sigma);
        K = Ks/2; varDbin = 2 * sigma^2 * vD / 4;
    end
end
[Pe, Po, Pa] = clipped_moments(B, T, sigma);
switch opt.snrMode
    case 'elec', P = Pe;
    case 'ac',   P = Pa;
    case 'opt',  P = Po^2;
    case 'peak', P = T^2;
end
ber = zeros(size(EbN0dB));
for i = 1:numel(EbN0dB)
    sn2 = N * P / (2 * nb * 10^(EbN0dB(i)/10));
    g = K^2 ./ (varDbin + sn2 ./ H2);
    ber(i) = mean(ber_qam_awgn(M, g));
end
info.K = K; info.varDbin = varDbin; info.Pelec = Pe; info.Popt = Po; info.Pac = Pa;
info.se = nb / (N + opt.Ncp);
end
