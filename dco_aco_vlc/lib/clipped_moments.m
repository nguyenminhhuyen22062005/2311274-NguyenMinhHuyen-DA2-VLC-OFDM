function [Pelec, Popt, Pac] = clipped_moments(B, T, sigma)
% CLIPPED_MOMENTS  Moment cua y = clip(x + B, 0, T), x ~ N(0, sigma^2)
% (tich phan so). Dung de tinh cong suat phat ly thuyet cho DCO (B = mu*sigma)
% va ACO (B = 0).
z  = linspace(-12, 12, 40001);
w  = exp(-z.^2/2) / sqrt(2*pi);
y  = min(max(sigma*z + B, 0), T);
Pelec = trapz(z, w .* y.^2);
Popt  = trapz(z, w .* y);
Pac   = Pelec - Popt^2;
end
