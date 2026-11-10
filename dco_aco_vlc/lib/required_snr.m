function s = required_snr(EbN0dB, ber, target)
% REQUIRED_SNR  Noi suy Eb/N0 can thiet de dat BER = target
% (noi suy tuyen tinh log10(BER) theo dB). Tra ve NaN neu khong dat.
s = NaN;
ok = ~isnan(ber) & ber > 0;
EbN0dB = EbN0dB(ok); ber = ber(ok);
i = find(ber <= target, 1, 'first');
if isempty(i) || i == 1
    if ~isempty(i) && i == 1, s = EbN0dB(1); end
    return;
end
x1 = EbN0dB(i-1); x2 = EbN0dB(i);
y1 = log10(ber(i-1)); y2 = log10(ber(i));
s = x1 + (log10(target) - y1) * (x2 - x1) / (y2 - y1);
end
