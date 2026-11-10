function y = nanpos(y)
% NANPOS  Thay cac gia tri <= 0 (BER = 0, khong co loi) bang NaN de ve thang log.
y(~(y > 0)) = NaN;
end
