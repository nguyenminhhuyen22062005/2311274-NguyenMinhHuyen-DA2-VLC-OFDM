function y = aco_clip(x, clipTop)
% ACO_CLIP  Xen toan bo phan am cua tin hieu ACO-OFDM (khong can DC bias).
% Do chi dung song mang le va tin hieu co tinh phan doi xung
% x[n + N/2] = -x[n], nhieu xen chi roi vao song mang chan.
if nargin < 2, clipTop = Inf; end
y = x;
y(y < 0) = 0;
y(y > clipTop) = clipTop;
end
