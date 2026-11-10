function [b, a, H, f3dB_eff] = led_lowpass(beta, N)
% LED_LOWPASS  Mo hinh bang thong LED: bo loc thong thap bac 1 voi dap ung xung
%       h(t) = 2*pi*fc * exp(-2*pi*fc*t)      <->   H(f) = 1/(1 + j f/fc)
% roi rac hoa bat bien xung (impulse invariance) tai tan so lay mau fs:
%       h[n] = (1 - p) * p^n ,   p = exp(-2*pi*fc/fs)
% Day chinh la mo hinh led_lp_channel.m cua repo SamuelDSR/VLC
% (h = exp(-2*pi*fc*t), chuan hoa sum(h) = 1 -> do loi DC = 1), nhung duoc
% cai dat dang IIR (khong bi cat cut so tap).
%   beta : bang thong LED chuan hoa  beta = fc / (fs/2)
%          (fs/2 = tan so cua song mang cao nhat = bang thong tin hieu)
%          beta = Inf -> LED ly tuong
%   N    : kich thuoc FFT (de tra ve H tai cac bin FFT, dung cho can bang ZF)
%   b, a : he so dung voi filter(b, a, x)
%   H    : dap ung tan so tai k = 0..N-1 (N x 1)
%   f3dB_eff : tan so -3 dB thuc te cua bo loc roi rac, chuan hoa theo fs/2
%          (lech so voi beta khi beta lon do hien tuong chong pho)
% Dap ung xung luon duong => tin hieu sau LED van khong am (dung voi IM/DD).
if isinf(beta)
    b = 1; a = 1; p = 0;
else
    p = exp(-pi * beta);          % 2*pi*fc/fs = pi*beta
    b = 1 - p;
    a = [1 -p];
end
if nargin >= 2
    z = exp(-1j*2*pi*(0:N-1).'/N);
    H = b ./ (1 - p*z);
end
if nargout >= 4
    if p == 0
        f3dB_eff = Inf;
    else
        c = (1 + p^2 - 2*(1-p)^2) / (2*p);   % cos(w3dB)
        if c < -1, f3dB_eff = Inf; else, f3dB_eff = acos(c)/pi; end
    end
end
end
