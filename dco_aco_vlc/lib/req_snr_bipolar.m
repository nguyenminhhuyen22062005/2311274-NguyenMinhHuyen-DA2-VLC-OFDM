function s = req_snr_bipolar(M, target)
% REQ_SNR_BIPOLAR  Eb/N0 (dB) de OFDM luong cuc ly tuong (M-QAM, AWGN, khong
% DC, khong clipping) dat BER = target. Dung lam moc tinh power penalty.
lo = -5; hi = 60;
for it = 1:60
    mid = (lo + hi)/2;
    if ber_qam_awgn(M, log2(M)*10^(mid/10)) > target, lo = mid; else, hi = mid; end
end
s = (lo + hi)/2;
end
