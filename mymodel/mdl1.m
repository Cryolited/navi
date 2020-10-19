%% INPUT DATA
% https://ru.wikipedia.org/wiki/%D0%A4%D1%83%D0%BD%D0%BA%D1%86%D0%B8%D1%8F_%D0%A5%D0%B8%D0%BC%D0%BC%D0%B5%D0%BB%D1%8C%D0%B1%D0%BB%D0%B0%D1%83

f = @(x)((x(1)^2 + x(2) - 11)^2 + (x(2)^2 + x(1) - 7)^2);

% [X Y] = meshgrid(-5:0.01:5);
% Z = (X.^2 + Y - 11).^2 + (X + Y.^2 - 7).^2;
% mesh(X, Y, Z)

x1_0 = [1  3.58443 3 -3.77931 -2.851181];
x2_0 = [1 -1.84813 2 -3.28318  3.13131];

%syms x1 x2
%fun = (x1^2 + x2 - 11)^2 + (x2^2 + x1 - 7)^2;

% df1 = diff(fun, x1);
% df2 = diff(fun, x2);
% x1 = 1.9992;
% x2 = -1.5232;
% eval(df1)
% eval(df2)

Ind = 5;
 x0 = [x1_0(Ind) x2_0(Ind)];
 opt = optimset('display', 'iter')
 [x f flag mes] = fminsearch(f, x0, opt)
% 
% opt = optimset('display', 'iter', 'hessupdate', 'bfgs')
% [x f flag mes] = fminunc(f, x0, opt)