%
% direct_mono.m
%
% Copyright (C) 2013 Mathieu Gaborit (matael) <mathieu@matael.org>
%
%
% Distributed under WTFPL terms
%
%            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
%                    Version 2, December 2004
%
% Copyright (C) 2004 Sam Hocevar <sam@hocevar.net>
%
% Everyone is permitted to copy and distribute verbatim or modified
% copies of this license document, and changing it is allowed as long
% as the name is changed.
%
%            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
%   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
%
%  0. You just DO WHAT THE FUCK YOU WANT TO.
%

clear all;
close all;

% get meas data
run 'mesures/directivite_monopole.data';

meas_data = norm2one(meas_data);

% gh = polar(angles, meas_data(:,2));
% set(gh, 'LineWidth', 3)
% polargrid;
% ax = axis();
% ylim([0 max(abs(ax(1:4)))]);

dirplot(meas_data(:,1)*180/pi, meas_data(:,2));
title("Directivite du monopole");
print('-dpng', 'direct_mono.png');
