function fig_axes(ax)
% FIG_AXES  Dinh dang truc chung cho moi hinh cua bao cao.
if nargin < 1, ax = gca; end
set(ax, 'FontName', 'Times New Roman', 'FontSize', 10, 'Box', 'on', 'LineWidth', 0.8);
grid(ax, 'on');
end
