function bits = qam_gray_demod(r, M)
% QAM_GRAY_DEMOD  Giai dieu che quyet dinh cung (hard decision) cho M-QAM Gray,
% tuong ung voi qam_gray_mod (E[|s|^2] = 1).
%   r    : vector ky hieu phuc nhan duoc (da can bang kenh)
%   bits : ma tran (k x numel(r))
k  = log2(M);
kI = k/2;
L  = sqrt(M);
r  = r(:).' * sqrt(2*(M-1)/3);
bits = [level_to_gray_bits(real(r), kI, L); level_to_gray_bits(imag(r), kI, L)];
end

function g = level_to_gray_bits(v, kI, L)
n = round((v + (L-1))/2);       % chi so muc gan nhat
n = min(max(n, 0), L-1);
b = zeros(kI, numel(v));
for i = 1:kI                    % nhi phan, MSB truoc
    p = 2^(kI-i);
    b(i,:) = floor(n / p);
    n = n - b(i,:)*p;
end
g = b;
for i = 2:kI                    % nhi phan -> Gray
    g(i,:) = xor(b(i-1,:), b(i,:));
end
end
