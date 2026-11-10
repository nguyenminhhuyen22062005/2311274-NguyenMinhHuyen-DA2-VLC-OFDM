function x = ofdm_ifft_hermitian(X, scheme, N, L)
% OFDM_IFFT_HERMITIAN  Dat du lieu len song mang, tao doi xung Hermitian
% X[N-k] = conj(X[k]), X[0] = X[N/2] = 0 => tin hieu mien thoi gian la so THUC.
%   X : ma tran (Nd x Nsym) ky hieu QAM
%   L : he so lay mau tang (oversampling, mac dinh 1). L > 1 chi dung cho PAPR.
%   x : ma tran (L*N x Nsym), chuan hoa sao cho E[x^2] = 2*Nd/N (IFFT unitary)
if nargin < 4, L = 1; end
idx  = ofdm_subcarriers(scheme, N);
Nsym = size(X, 2);
F = zeros(L*N, Nsym);
F(idx, :) = X;                                  % nua duong cua pho
F(L*N - idx + 2, :) = conj(X);                  % anh lien hop Hermitian
x = real(ifft(F)) * L * sqrt(N);                % giu E[x^2] = 2*Nd/N voi moi L
% (phan ao chi la sai so lam tron ~1e-17, bo di)
end
