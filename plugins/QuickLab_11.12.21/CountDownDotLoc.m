function CountDownDotLoc(axis)

if nargin < 1
    axisPanel = findobj('Tag','PieChart');
    axis = findobj('Tag','pie_chart');
end

%axis = axes(axis, 'Tag','pie_chart','Position', [0 0 1 1]);

A = dir('*EP63.set');
B = dir('*EP60.set');
C = cat(1,A,B);
total = length(C);

D = dir('*.set');
F = [D.name];
totalstarted = 0;

for i = 1:total
    
    G = strfind(F,C(i).name(1:end-4));
    H = length(G);
    
    if H > 1
        totalstarted = totalstarted + 1;
    end

end

totalleft = total-totalstarted;
% total
% totalstarted
% totalstarted/total*100

pie(axis,[totalleft,totalstarted],{num2str(totalleft),num2str(totalstarted)})

% pie([total-totalstarted,totalstarted])