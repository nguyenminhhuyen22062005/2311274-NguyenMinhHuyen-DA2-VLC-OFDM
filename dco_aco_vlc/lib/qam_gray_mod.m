function s = qam_gray_mod(bits, M)
% QAM_GRAY_MOD  Dieu che M-QAM vuong, ma Gray, chuan hoa E[|s|^2] = 1.
%   bits : ma tran (k x Nsym) hoac vector cot, k = log2(M) (M = 4, 16, 64, 256)
%   s    : vector hang (1 x Nsym) ky hieu phuc
% Thay the cho modem.qammod (API cu, da bi loai bo trong MATLAB moi) ma
% repo SamuelDSR/VLC dang dung. Khong can Communications Toolbox.
k  = log2(M);
kI = k/2;                       % so bit cho moi truc I/Q
L  = sqrt(M);                   % so muc PAM moi truc
bits = reshape(bits, k, []);
levI = gray_bits_to_level(bits(1:kI, :), kI, L);
levQ = gray_bits_to_level(bits(kI+1:end, :), kI, L);
s = (levI + 1j*levQ) / sqrt(2*(M-1)/3);
end

function lev = gray_bits_to_level(g, kI, L)
% Gray -> nhi phan -> chi so n -> muc PAM {-(L-1),...,L-1}
b = zeros(size(g));
b(1,:) = g(1,:);
for i = 2:kI
    b(i,:) = xor(b(i-1,:), g(i,:));
end
n = (2.^(kI-1:-1:0)) * b;       % gia tri nguyen 0..L-1
lev = 2*n - (L-1);
end
