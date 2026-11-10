function pb = ber_qam_awgn(M, EsN0)
% BER_QAM_AWGN  BER ly thuyet (xap xi chat) cua M-QAM vuong ma Gray tren AWGN.
%   EsN0 : SNR tren moi ky hieu (tuyen tinh), co the la ma tran
%   Pb ~ (4/k)(1-1/sqrt(M)) * sum_{i=1}^{min(2,sqrt(M)/2)} Q((2i-1) sqrt(3 EsN0/(M-1)))
k = log2(M);
L = sqrt(M);
pb = zeros(size(EsN0));
for i = 1:min(2, L/2)
    pb = pb + qfun((2*i-1) * sqrt(3*EsN0/(M-1)));
end
pb = (4/k) * (1 - 1/L) * pb;
end
