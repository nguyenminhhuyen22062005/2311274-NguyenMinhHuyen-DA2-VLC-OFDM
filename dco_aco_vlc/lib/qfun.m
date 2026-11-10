function q = qfun(x)
% QFUN  Ham Q(x) = P(Z > x), Z ~ N(0,1). Thay cho qfunc (Communications Toolbox).
q = 0.5 * erfc(x / sqrt(2));
end
