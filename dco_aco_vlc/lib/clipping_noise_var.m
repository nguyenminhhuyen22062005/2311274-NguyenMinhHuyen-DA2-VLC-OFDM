function [K, varD] = clipping_noise_var(lb, lt)
% CLIPPING_NOISE_VAR  He so Bussgang K va phuong sai nhieu xen (chuan hoa theo
% sigma^2) khi tin hieu Gauss N(0,1) bi xen trong [lb, lt].
% Port tu OFDM_Noise/dco_clipping_noise.m cua repo SamuelDSR/VLC
% (cong thuc Dimitrov et al., IEEE TCOM 2012), sua loi NaN khi lt = Inf
% (Q(Inf)*Inf = 0*Inf = NaN trong MATLAB).
lb = max(lb, -40); lt = min(lt, 40);          % tranh 0*Inf
phi = @(t) exp(-t.^2/2) / sqrt(2*pi);
K = qfun(lb) - qfun(lt);
m = phi(lb) - phi(lt) + (1 - qfun(lb)).*lb + qfun(lt).*lt;   % E[y]
e2 = K + (1 - qfun(lb)).*lb.^2 + qfun(lt).*lt.^2 + phi(lb).*lb - phi(lt).*lt; % E[y^2]
varD = e2 - m.^2 - K.^2;                       % var(y) - K^2
end
