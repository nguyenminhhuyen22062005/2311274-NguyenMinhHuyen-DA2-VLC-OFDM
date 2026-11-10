function [y, B] = dco_bias_clip(x, biasdB, sigma, clipTop)
% DCO_BIAS_CLIP  Cong DC bias va xen (clip) tin hieu cho DCO-OFDM.
%   Bias duoc dat ti le voi do lech chuan sigma cua tin hieu luong cuc:
%       B = mu*sigma,   biasdB = 10*log10(1 + mu^2)   (dinh nghia Armstrong)
%   Phan am sau khi cong bias bi xen ve 0 (nguong bat cua LED, da chuan hoa),
%   neu co clipTop (gioi han dong toi da cua LED) thi xen ca phia tren.
if nargin < 4, clipTop = Inf; end
mu = sqrt(10^(biasdB/10) - 1);
B  = mu * sigma;
y  = x + B;
y(y < 0) = 0;
y(y > clipTop) = clipTop;
end
