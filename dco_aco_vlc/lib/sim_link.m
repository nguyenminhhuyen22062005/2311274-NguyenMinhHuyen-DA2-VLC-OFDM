function res = sim_link(scheme, EbN0dB, opt)
% SIM_LINK  Mo phong Monte Carlo BER cho mot cau hinh DCO-OFDM hoac ACO-OFDM.
%
%   res = sim_link('dco', 0:2:24, opt)
%
%   Cac truong cua opt (deu co gia tri mac dinh, xem default_opt()):
%     N, Ncp      kich thuoc FFT, do dai CP (mau)
%     M           bac dieu che QAM
%     biasdB      DC bias cua DCO-OFDM (dB), dinh nghia 10log10(1+mu^2)
%     clipTop     gioi han tren cua LED (Inf = khong xen tren), cung don vi
%                 voi tin hieu (sigma cua tin hieu luong cuc DCO = sqrt(2Nd/N))
%     beta        bang thong LED chuan hoa f3dB/(fs/2), Inf = ly tuong
%     snrMode     'elec' : Eb/N0 tinh theo cong suat dien E[x^2] (CO tinh DC)
%                 'ac'   : chi tinh cong suat xoay chieu var(x) (KHONG tinh DC)
%                 'opt'  : Eb(opt)/N0, dung (E[x])^2 thay cho E[x^2]
%                 'peak' : nhieu tham chieu theo cong suat dinh clipTop^2 (LED
%                          gioi han dai dong; dung cho khao sat clipping)
%     nSymBatch   so ky hieu OFDM moi lan lap
%     minErr      dung khi dem du so loi bit nay ...
%     maxBits     ... hoac khi da mo phong du so bit nay
%     minBER      bo qua cac diem SNR tiep theo khi BER < minBER
%
%   Dinh nghia SNR (khong tinh nang luong CP, giong nhau cho ca 2 he thong):
%       Eb/N0 = N * P / (2 * nb * sigma_n^2)
%   voi P la cong suat tin hieu phat (dau vao LED, sau bias & clipping),
%   nb = Nd*log2(M) so bit / ky hieu OFDM, sigma_n^2 phuong sai nhieu moi mau.
%
%   Ket qua: res.ber, res.nErr, res.nBits, res.Pelec, res.Popt, res.Pac, res.se

if nargin < 3, opt = struct(); end
opt = fill_defaults(opt);

N = opt.N; Ncp = opt.Ncp; M = opt.M; k = log2(M);
[idx, Nd] = ofdm_subcarriers(scheme, N);
nb    = Nd * k;                         % bit / ky hieu OFDM
sigma = sqrt(2*Nd/N);                   % do lech chuan tin hieu luong cuc
[bL, aL, H] = led_lowpass(opt.beta, N);
Hd = H(idx);                            % dap ung LED tai cac song mang du lieu

nPts = numel(EbN0dB);
res.EbN0dB = EbN0dB;
res.ber   = nan(1, nPts);
res.nErr  = zeros(1, nPts);
res.nBits = zeros(1, nPts);
res.Pelec = nan(1, nPts); res.Popt = nan(1, nPts); res.Pac = nan(1, nPts);
res.se    = nb / (N + Ncp);             % hieu suat pho (bit/s/Hz, quy uoc B = fs)
res.scheme = scheme; res.opt = opt;

for ip = 1:nPts
    nErr = 0; nBits = 0; Pe = 0; Po = 0; Pa = 0; nb_ = 0;
    while nErr < opt.minErr && nBits < opt.maxBits
        Ns = opt.nSymBatch;
        % ---------------- Phat ----------------
        bits = randi([0 1], k, Nd*Ns);
        X = reshape(qam_gray_mod(bits, M), Nd, Ns);     % E|X|^2 = 1
        x = ofdm_ifft_hermitian(X, scheme, N);          % tin hieu thuc, luong cuc
        if strcmpi(scheme, 'dco')
            y = dco_bias_clip(x, opt.biasdB, sigma, opt.clipTop);
        else
            y = aco_clip(x, opt.clipTop);               % ACO: xen phan am
        end
        y  = [y(end-Ncp+1:end, :); y];                  % them CP
        ys = y(:);                                      % chuoi noi tiep
        % cong suat tin hieu phat (dau vao LED)
        Pe_b = mean(ys.^2); Po_b = mean(ys); Pa_b = var(ys);
        switch opt.snrMode
            case 'elec', P = Pe_b;
            case 'ac',   P = Pa_b;
            case 'opt',  P = Po_b^2;
            case 'peak', P = opt.clipTop^2;
            otherwise, error('snrMode khong hop le');
        end
        % ---------------- LED (thong thap) + nhieu AWGN ----------------
        r = filter(bL, aL, ys);
        sn2 = N * P / (2 * nb * 10^(EbN0dB(ip)/10));
        r = r + sqrt(sn2) * randn(size(r));
        % ---------------- Thu ----------------
        R = reshape(r, N + Ncp, Ns);
        R = R(Ncp+1:end, :);                            % bo CP
        Y = fft(R) / sqrt(N);                           % FFT unitary
        Yd = Y(idx, :);
        Yd = Yd ./ repmat(Hd, 1, Ns);                   % can bang ZF 1-tap
        % he so khuech dai hieu dung (Bussgang): ACO ~ 1/2, DCO = 1 - Q(mu)
        % -> uoc luong bang ky hieu da biet (tuong duong pilot dai, CSI ly tuong)
        g = real(sum(Yd(:) .* conj(X(:)))) / sum(abs(X(:)).^2);
        bh = qam_gray_demod(Yd(:) / g, M);
        nErr  = nErr + sum(bh(:) ~= bits(:));
        nBits = nBits + numel(bits);
        Pe = Pe + Pe_b; Po = Po + Po_b; Pa = Pa + Pa_b; nb_ = nb_ + 1;
    end
    res.ber(ip) = nErr / nBits;
    res.nErr(ip) = nErr; res.nBits(ip) = nBits;
    res.Pelec(ip) = Pe/nb_; res.Popt(ip) = Po/nb_; res.Pac(ip) = Pa/nb_;
    if opt.verbose
        if strcmpi(scheme, 'dco'), btxt = sprintf(' bias=%gdB', opt.biasdB); else, btxt = ''; end
        fprintf('  %s M=%d%s beta=%g  Eb/N0=%5.1f dB  BER=%.3e (%d loi/%d bit)\n', ...
            upper(scheme), M, btxt, opt.beta, EbN0dB(ip), res.ber(ip), nErr, nBits);
    end
    if res.ber(ip) < opt.minBER, break; end
end
end

function opt = fill_defaults(opt)
d = default_opt();
f = fieldnames(d);
for i = 1:numel(f)
    if ~isfield(opt, f{i}), opt.(f{i}) = d.(f{i}); end
end
end
