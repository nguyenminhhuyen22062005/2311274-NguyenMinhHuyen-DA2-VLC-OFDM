function s = required_snr_theory(scheme, target, opt)
% REQUIRED_SNR_THEORY  Eb/N0 can thiet (giai tich) de BER = target, tim bang
% chia doi. NaN neu khong dat (san loi do nhieu xen).
lo = -10; hi = 80;
if ber_theory(scheme, hi, opt) > target, s = NaN; return; end
for it = 1:60
    mid = (lo + hi)/2;
    if ber_theory(scheme, mid, opt) > target, lo = mid; else, hi = mid; end
end
s = (lo + hi)/2;
end
